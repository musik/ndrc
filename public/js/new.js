define("lib/er/util",
function() {
    var now = +new Date,
    util = {};
    util.guid = function() {
        return "er" + now++
    },
    util.mix = function(e) {
        for (var t = 1; t < arguments.length; t++) {
            var n = arguments[t];
            if (n) for (var i in n) n.hasOwnProperty(i) && (e[i] = n[i])
        }
        return e
    };
    var nativeBind = Function.prototype.bind;
    util.bind = nativeBind ?
    function(e) {
        return nativeBind.apply(e, [].slice.call(arguments, 1))
    }: function(e, t) {
        var n = [].slice.call(arguments, 2);
        return function() {
            var i = n.concat([].slice.call(arguments));
            return e.apply(t, i)
        }
    },
    util.noop = function() {},
    util.inherits = function(e, t) {
        var n = function() {};
        n.prototype = t.prototype;
        var i = new n,
        r = e.prototype;
        e.prototype = i;
        for (var a in r) i[a] = r[a];
        return e.prototype.constructor = e,
        e
    },
    util.parseJSON = function(text) {
        return window.JSON && "function" == typeof JSON.parse ? JSON.parse(text) : eval("(" + text + ")")
    };
    var whitespace = /(^[\s\t\xa0\u3000]+)|([\u3000\xa0\s\t]+$)/g;
    return util.trim = function(e) {
        return e.replace(whitespace, "")
    },
    util.encodeHTML = function(e) {
        return e += "",
        e.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;")
    },
    util
}),
define("lib/er/URL",
function(require) {
    function e(n, i, r) {
        n = n || "/",
        i = i || "",
        r = r || "~",
        this.toString = function() {
            return i ? n + r + i: n
        },
        this.getPath = function() {
            return n
        },
        this.getSearch = function() {
            return i
        };
        var a = null;
        this.getQuery = function(n) {
            return a || (a = e.parseQuery(i)),
            n ? a[n] : t.mix({},
            a)
        }
    }
    var t = require("./util");
    return e.parse = function(n, i) {
        var r = {
            querySeparator: "~"
        };
        i = t.mix(r, i);
        var a = n.indexOf(i.querySeparator);
        return a >= 0 ? new e(n.slice(0, a), n.slice(a + 1), i.querySeparator) : new e(n, "", i.querySeparator)
    },
    e.withQuery = function(n, i, r) {
        n += "";
        var a = {
            querySeparator: "~"
        };
        r = t.mix(a, r);
        var o = n.indexOf(r.querySeparator) < 0 ? r.querySeparator: "&",
        s = e.serialize(i),
        u = n + o + s;
        return e.parse(u, r)
    },
    e.parseQuery = function(e) {
        for (var t = e.split("&"), n = {},
        i = 0; i < t.length; i++) {
            var r = t[i];
            if (r) {
                var a = r.indexOf("="),
                o = decodeURIComponent(0 > a ? r: r.slice(0, a)),
                s = 0 > a ? !0 : decodeURIComponent(r.slice(a + 1));
                n.hasOwnProperty(o) ? s !== !0 && (n[o] = [].concat(n[o], s)) : n[o] = s
            }
        }
        return n
    },
    e.serialize = function(e) {
        if (!e) return "";
        var t = "";
        for (var n in e) if (e.hasOwnProperty(n)) {
            var i = e[n];
            t += "&" + encodeURIComponent(n) + "=" + encodeURIComponent(i)
        }
        return t.slice(1)
    },
    e.empty = new e,
    e
}),
define("common/data",
function(require) {
    function e(e) {
        return e
    }
    var t = require("../lib/er/URL"),
    n = {},
    i = {},
    r = {},
    exports = {
        set: function(e, t) {
            if ("string" == typeof e) void 0 !== n[e] && (i[e] = n[e]),
            n[e] = t;
            else if ($.isPlainObject(e)) for (var r in e) exports.set(r, e[r])
        },
        setStore: function(e, t) {
            if ("string" == typeof e) $.isPlainObject(t) && (t = JSON.stringify(t)),
            store.set(e, t);
            else if ($.isPlainObject(e)) for (var n in e) store.set(n, e[n])
        },
        getStore: function(e) {
            try {
                var t = store.get(e);
                return JSON.parse(t)
            } catch(n) {
                return store.get(e)
            }
        },
        get: function(e) {
            return e ? n[e] : n
        },
        isChange: function(e) {
            var t = n[e],
            r = i[e];
            return void 0 !== r && t !== r
        },
        onChange: function(e, t) {
            var n = r[e];
            $.isArray(n) || (n = [], r[e] = n),
            n.push(t)
        },
        fireChange: function() {
            for (var e in n) if (exports.isChange(e)) {
                var t = r[e];
                if (t) for (var a = 0,
                o = t.length; o > a; a++)"function" == typeof t[a] && t[a]();
                i[e] = void 0
            }
        }
    },
    a = {
        fenlei: e,
        orgid: e,
        orgname: e,
        uiSid: e,
        zt: e,
        classID: e,
        categoryID: e,
        cardStyle: e,
        tags: function(e) {
            return e.split(",")
        }
    },
    o = window.location.search;
    if (o) {
        o = o.substr(1);
        var s, u = t.parseQuery(o);
        for (var l in a) s = u[l],
        null != s && exports.set(l, a[l](s))
    }
    return exports
}),
define("lib/zxui/lib",
function() {
    function generic(e) {
        return function() {
            return Function.call.apply(e, arguments)
        }
    }
    function fallback(e, t, n) {
        return e ? generic(n || e) : t
    }
    function getCompatElement(e) {
        var t = e && e.ownerDocument || document,
        n = t.compatMode;
        return n && "CSS1Compat" !== n ? t.body: t.documentElement
    }
    var lib = {},
    toString = Object.prototype.toString,
    hasOwnProperty = Object.prototype.hasOwnProperty,
    typeOf = lib.typeOf = function(e) {
        var t = toString.call(e).slice(8, -1).toLowerCase();
        return e && "object" == typeof e && "nodeType" in e ? "dom": null == e ? null: t
    },
    each = lib.each = fallback(Array.prototype.forEach,
    function(e, t, n) {
        for (var i = 0,
        r = e.length >>> 0; r > i; i++) i in e && t.call(n, e[i], i, e)
    });
    each(["String", "Array", "Function", "Date", "Object"],
    function(e) {
        var t = e.toLowerCase();
        lib["function" === t ? "fn": t] = {},
        lib["is" + e] = function(t) {
            return null != t && toString.call(t).slice(8, -1) === e
        }
    }),
    lib.array.each = each;
    var map = lib.map = lib.array.map = fallback(Array.prototype.map,
    function(e, t, n) {
        for (var i = 0,
        r = e.length; r > i; i++) i in e && (e[i] = t.call(n, e[i], i, e));
        return e
    }),
    indexOf = lib.indexOf = lib.array.indexOf = fallback(Array.prototype.indexOf,
    function(e, t, n) {
        for (var i = this.length >>> 0,
        r = 0 > n ? Math.max(0, i + n) : n || 0; i > r; r++) if (e[r] === t) return r;
        return - 1
    }),
    slice = lib.slice = lib.array.slice = generic(Array.prototype.slice);
    lib.toArray = lib.array.toArray = function(e) {
        if (null == e) return [];
        if (lib.isArray(e)) return e;
        var t = e.length;
        if ("number" == typeof t && "string" !== typeOf(e)) {
            for (var n = []; t--;) n[t] = e[t];
            return n
        }
        return [e]
    };
    var extend = lib.extend = lib.object.extend = function(e, t) {
        for (var n in t) hasOwnProperty.call(t, n) && (lib.isObject(e[n]) ? extend(e[n], t[n]) : e[n] = t[n]);
        return e
    },
    clone = lib.clone = lib.object.clone = function(e) {
        if (!e || "object" != typeof e) return e;
        var t = e;
        if (lib.isArray(e)) t = map(slice(e), clone);
        else if (lib.isObject(e) && "isPrototypeOf" in e) {
            t = {};
            for (var n in e) hasOwnProperty.call(e, n) && (t[n] = clone(e[n]))
        }
        return t
    };
    lib.stringify = lib.object.stringify = window.JSON && JSON.stringify ||
    function() {
        var e = {
            "\b": "\\b",
            "	": "\\t",
            "\n": "\\n",
            "\f": "\\f",
            "\r": "\\r",
            '"': '\\"',
            "\\": "\\\\"
        },
        t = function(t) {
            return e[t] || "\\u" + ("0000" + t.charCodeAt(0).toString(16)).slice( - 4)
        };
        return function n(e) {
            switch (e && e.toJSON && (e = e.toJSON()), typeOf(e)) {
            case "string":
                return '"' + e.replace(/[\x00-\x1f\\"]/g, t) + '"';
            case "array":
                return "[" + map(e, n) + "]";
            case "object":
                var i = [];
                for (var r in e) if (hasOwnProperty.call(e)) {
                    var a = n(value);
                    a && i.push(n(r) + ":" + a)
                }
                return "{" + i + "}";
            case "number":
            case "boolean":
                return "" + e;
            case "null":
                return "null"
            }
            return null
        }
    } (),
    lib.parse = lib.object.parse = window.JSON && JSON.parse ||
    function(string) {
        return string && "string" === typeOf(string) ? eval("(" + string + ")") : null
    },
    lib.toQueryString = lib.object = function e(t, n) {
        var i, r, a = [];
        for (var o in t) if (hasOwnProperty.call(t, o)) {
            switch (i = t[o], n && (o = n + "[" + o + "]"), typeOf(i)) {
            case "object":
                r = e(i, o);
                break;
            case "array":
                for (var s = {},
                u = i.length; u--;) s[u] = i[u];
                r = e(s, o);
                break;
            default:
                r = o + "=" + encodeURIComponent(i)
            }
            null != i && a.push(r)
        }
        return a.join("&")
    },
    lib.trim = lib.string.trim = function() {
        var e = /^[\s\xa0\u3000]+|[\u3000\xa0\s]+$/g;
        return function(t, n) {
            return t && String(t).replace(n || e, "") || ""
        }
    } (),
    lib.camelCase = lib.string.camelCase = function(e) {
        return String(e).replace(/-\D/g,
        function(e) {
            return e.charAt(1).toUpperCase()
        })
    },
    lib.capitalize = lib.string.capitalize = function(e) {
        return String(e).replace(/\b[a-z]/g,
        function(e) {
            return e.toUpperCase()
        })
    },
    lib.contains = lib.string.contains = function(e, t, n) {
        return n = n || " ",
        e = n + e + n,
        t = n + lib.trim(t) + n,
        e.indexOf(t) > -1
    },
    lib.pad = lib.string.pad = function(e, t) {
        var n = String(Math.abs(0 | e));
        return (0 > e ? "-": "") + (n.length >= t ? n: ((1 << t - n.length).toString(2) + n).slice( - t))
    },
    lib.bind = lib.fn.bind = fallback(Function.bind,
    function(e, t) {
        var n = arguments.length > 2 ? slice(arguments, 1) : null,
        i = function() {},
        r = function() {
            var a = t,
            o = arguments.length;
            this instanceof r && (i.prototype = e.prototype, a = new i);
            var s = n || o ? e.apply(a, n && o ? n.concat(slice(arguments)) : n || arguments) : e.call(a);
            return a === t ? s: a
        };
        return r
    }),
    lib.binds = lib.fn.binds = function(e, t) {
        if ("string" == typeof t && (t = ~t.indexOf(",") ? t.split(/\s*,\s*/) : slice(arguments, 1)), t && t.length) for (var n, i; n = t.pop();) i = n && e[n],
        i && (e[n] = lib.bind(i, e))
    };
    var curry = lib.curry = lib.fn.curry = function(e) {
        var t = slice(arguments, 1);
        return function() {
            return e.apply(this, t.concat(slice(arguments)))
        }
    }; !
    function() {
        function e(e, n) {
            var i = lib.newClass(),
            r = function() {};
            return r.prototype = e.prototype,
            i.prototype = new r,
            i.prototype.parent = curry(t, e),
            i.implement(n),
            i
        }
        function t(e, t) {
            var n = e.prototype[t];
            if (n) return n.apply(this, slice(arguments, 2));
            throw new Error("parent Class has no method named " + t)
        }
        function n(e, t) {
            lib.isFunction(t) && (t = t.prototype);
            for (var n in t) hasOwnProperty.call(t, n) && (e.prototype[n] = t[n]);
            return e
        }
        lib.newClass = function(t, i) {
            lib.isObject(t) && (i = t);
            var r = function() {
                var e = this.initialize ? this.initialize.apply(this, arguments) : this;
                return lib.isFunction(t) && (e = t.apply(this, arguments)),
                e
            };
            return r.prototype = i || {},
            r.prototype.constructor = r,
            r.extend = curry(e, r),
            r.implement = curry(n, r),
            r
        }
    } (),
    lib.observable = {
        on: function(e, t) {
            lib.isFunction(e) && (t = e, e = "*"),
            this._listeners = this._listeners || {};
            var n = this._listeners[e] || [];
            return indexOf(n, t) < 0 && (t.$type = e, n.push(t)),
            this._listeners[e] = n,
            this
        },
        un: function(e, t) {
            lib.isFunction(e) && (t = e, e = "*"),
            this._listeners = this._listeners || {};
            var n = this._listeners[e];
            if (n) if (t) {
                var i = indexOf(n, t);~i && delete n[i]
            } else n.length = 0,
            delete this._listeners[e];
            return this
        },
        fire: function(e, t) {
            this._listeners = this._listeners || {};
            var n = this._listeners[e];
            return n && each(n,
            function(n) {
                t = t || {},
                t.type = e,
                n.call(this, t)
            },
            this),
            "*" !== e && this.fire("*", t),
            this
        }
    },
    lib.configurable = {
        setOptions: function(e) {
            if (!e) return clone(this.options);
            var t = this.options = clone(this.options),
            n = /^on[A-Z]/,
            i = this;
            this.srcOptions = e;
            var r;
            for (var a in e) if (hasOwnProperty.call(e, a)) if (r = e[a], n.test(a) && lib.isFunction(r)) {
                var o = a.charAt(2).toLowerCase() + a.slice(3);
                i.on(o, r),
                delete e[a]
            } else a in t && (t[a] = "object" === typeOf(r) ? extend(t[a] || {},
            r) : r);
            return t
        }
    };
    var eventFix = {
        list: [],
        custom: {}
    };
    if (lib.event = {},
    lib.on = lib.event.on = document.addEventListener ?
    function(e, t, n) {
        var i = n,
        r = eventFix.custom[t],
        a = t;
        return r && (a = r.base, i = function(i) {
            r.condition.call(e, i, t) && (i._type = t, n.call(e, i))
        },
        n.index = eventFix.list.length, eventFix.list[n.index] = i),
        e.addEventListener(a, i, !!arguments[3])
    }: function(e, t, n) {
        return e.attachEvent("on" + t, n)
    },
    lib.un = lib.event.on = document.removeEventListener ?
    function(e, t, n) {
        var i = n,
        r = eventFix.custom[t],
        a = t;
        return r && (a = r.base, i = eventFix.list[n.index], delete eventFix.list[n.index], delete n.index),
        e.removeEventListener(a, i, !!arguments[3]),
        e
    }: function(e, t, n) {
        return e.detachEvent("on" + t, n),
        e
    },
    lib.fire = lib.event.fire = document.createEvent ?
    function(e, t) {
        var n = eventFix.custom[t],
        i = t;
        n && (i = n.base);
        var r = document.createEvent("HTMLEvents");
        return r.initEvent(i, !0, !0),
        e.dispatchEvent(r),
        e
    }: function(e, t) {
        var n = document.createEventObject();
        return e.fireEvent("on" + t, n),
        e
    },
    lib.getTarget = lib.event.getTarget = function(e) {
        return e = e || window.event,
        e.target || e.srcElement
    },
    lib.preventDefault = lib.event.preventDefault = fallback(window.Event && Event.prototype.preventDefault,
    function() {
        event.returnValue = !1
    }), lib.stopPropagation = lib.event.stopPropagation = fallback(window.Event && Event.prototype.stopPropagation,
    function() {
        event.cancelBubble = !0
    }), !("onmouseenter" in document)) {
        var check = function(e) {
            var t = e.relatedTarget;
            return null == t ? !0 : t ? t !== this && "xul" !== t.prefix && 9 !== this.nodeType && !lib.contains(this, t) : !1
        };
        eventFix.custom.mouseenter = {
            base: "mouseover",
            condition: check
        },
        eventFix.custom.mouseleave = {
            base: "mouseout",
            condition: check
        }
    } !
    function() {
        var e = /(opera|ie|firefox|chrome|version)[\s\/:]([\w\d\.]+)?.*?(safari|version[\s\/:]([\w\d\.]+)|$)/,
        t = navigator.userAgent.toLowerCase().match(e) || [null, "unknown", 0],
        n = "ie" === t[1] && document.documentMode,
        i = lib.browser = {
            name: "version" === t[1] ? t[3] : t[1],
            version: n || parseFloat("opera" === t[1] && t[4] ? t[4] : t[2])
        };
        i[i.name] = 0 | i.version,
        i[i.name + (0 | i.version)] = !0
    } (),
    lib.page = {},
    lib.getScrollLeft = lib.page.getScrollLeft = function() {
        return window.pageXOffset || getCompatElement().scrollLeft
    },
    lib.getScrollTop = lib.page.getScrollTop = function() {
        return window.pageYOffset || getCompatElement().scrollTop
    },
    lib.getViewWidth = lib.page.getViewWidth = function() {
        return getCompatElement().clientWidth
    },
    lib.getViewHeight = lib.page.getViewHeight = function() {
        return getCompatElement().clientHeight
    },
    lib.dom = {},
    lib.g = lib.dom.g = function(e) {
        return "string" === typeOf(e) ? document.getElementById(e) : e
    },
    lib.q = lib.dom.q = document.getElementsByClassName ?
    function(e, t) {
        return slice((t || document).getElementsByClassName(e))
    }: function(e, t) {
        t = t || document;
        for (var n = t.getElementsByTagName("*"), i = [], r = 0, a = n.length; a > r; r++) lib.contains(n[r].className, e) && i.push(n[r]);
        return i
    },
    lib.getAncestorBy = lib.dom.getAncestorBy = function(e, t, n) {
        for (; (e = e.parentNode) && 1 === e.nodeType;) if (t(e, n)) return e;
        return null
    },
    lib.getAncestorByClass = lib.dom.getAncestorByClass = function(e, t) {
        return lib.getAncestorBy(e, lib.hasClass, t)
    };
    var hasClassList = "classList" in document.documentElement;
    lib.hasClass = lib.dom.hasClass = hasClassList ?
    function(e, t) {
        return e.classList.contains(t)
    }: function(e, t) {
        return lib.contains(e.className, t)
    },
    lib.addClass = lib.dom.addClass = hasClassList ?
    function(e, t) {
        return e.classList.add(t),
        e
    }: function(e, t) {
        return lib.hasClass(e, t) || (e.className += " " + t),
        e
    },
    lib.removeClass = lib.dom.removeClass = hasClassList ?
    function(e, t) {
        return e.classList.remove(t),
        e
    }: function(e, t) {
        return e.className = e.className.replace(new RegExp("(^|\\s)" + t + "(?:\\s|$)"), "$1"),
        e
    },
    lib.toggleClass = lib.dom.toggleClass = hasClassList ?
    function(e, t) {
        return e.classList.toggle(t),
        e
    }: function(e, t) {
        var n = e.className,
        i = n && lib.contains(e, t);
        return e.className = i ? n.replace(new RegExp("(^|\\s)" + t + "(?:\\s|$)"), "$1") : n + " " + t,
        e
    },
    lib.show = lib.dom.show = function(e, t) {
        return e.style.display = t || "",
        e
    },
    lib.hide = lib.dom.hide = function(e) {
        return e.style.display = "none",
        e
    },
    lib.getStyle = lib.dom.getStyle = function(e, t) {
        if (!e) return "";
        t = lib.camelCase(t);
        var n = 9 === e.nodeType ? e: e.ownerDocument || e.document;
        if (n.defaultView && n.defaultView.getComputedStyle) {
            var i = n.defaultView.getComputedStyle(e, null);
            if (i) return i[t] || i.getPropertyValue(t)
        } else if (e && e.currentStyle) return e.currentStyle[t];
        return ""
    },
    lib.getPosition = lib.dom.getPosition = function(e) {
        var t = e.getBoundingClientRect(),
        n = document.documentElement,
        i = document.body,
        r = n.clientTop || i.clientTop || 0,
        a = n.clientLeft || i.clientLeft || 0,
        o = window.pageYOffset || n.scrollTop,
        s = window.pageXOffset || n.scrollLeft;
        return {
            left: (0 | t.left) + s - a,
            top: (0 | t.top) + o - r
        }
    },
    lib.setStyles = lib.dom.setStyles = function(e, t) {
        for (var n in t) hasOwnProperty.call(t, n) && (e.style[lib.camelCase(n)] = t[n])
    };
    var guidCounter = 2327;
    lib.guid = lib.dom.guid = function(e) {
        var t = 0 | e.getAttribute("data-guid");
        return t || (t = guidCounter++, e.setAttribute("data-guid", t)),
        t
    };
    var walk = function(e, t, n, i, r) {
        for (var a = lib.g(e)[n || t], o = []; a;) {
            if (1 === a.nodeType && (!i || i(a))) {
                if (!r) return a;
                o.push(a)
            }
            a = a[t]
        }
        return r ? o: null
    };
    return lib.extend(lib.dom, {
        previous: function(e, t) {
            return walk(e, "previousSibling", null, t)
        },
        next: function(e, t) {
            return walk(e, "nextSibling", null, t)
        },
        first: function(e, t) {
            return walk(e, "nextSibling", "firstChild", t)
        },
        last: function(e, t) {
            return walk(e, "previousSibling", "lastChild", t)
        },
        children: function(e, t) {
            return walk(e, "nextSibling", "firstChild", t, !0)
        },
        contains: function(e, t) {
            var n = lib.g;
            return e = n(e),
            t = n(t),
            e.contains ? e !== t && e.contains(t) : !!(8 & t.compareDocumentPosition(e))
        }
    }),
    lib
}),
define("lib/zxui/log",
function(require) {
    var e = require("./lib"),
    t = function(e) {
        try {
            return new Function("return (" + e + ")")()
        } catch(t) {
            return {}
        }
    },
    n = function() {
        var t = [];
        return function(n) {
            var i = t.push(document.createElement("img")) - 1;
            t[i].onload = t[i].onerror = function() {
                t[i] = t[i].onload = t[i].onerror = null,
                delete t[i]
            };
            var r = o.action + e.toQueryString(n);
            t[i].src = r + "&" + ( + new Date).toString(36),
            exports.fire("send", {
                url: r
            })
        }
    } (),
    i = function(n, i, o) {
        var s, u, l = 0,
        c = i,
        d = [],
        f = c.getAttribute("data-rsv");
        f && (n.rsv = e.extend(n, {
            rsv: t(f)
        }));
        for (var p, h = 0,
        g = /\bOP_LOG_(TITLE|LINK|IMG|BTN|INPUT|OTHERS)\b/i; c !== o;) {
            if ("1" === c.getAttribute("data-nolog")) {
                l = 1;
                break
            }
            p = c.getAttribute("data-click"),
            p && (n = e.extend(t(p), n)),
            f = c.getAttribute("data-rsv"),
            f && (n.rsv = e.extend(t(f), n.rsv)),
            c.href && (u = c.href, s = "link"),
            "link" === s && "H3" === c.tagName && (s = "title"),
            g.test(c.className) && (s = RegExp.$1.toLowerCase());
            var m = 1;
            if (c.previousSibling) {
                var v = c.previousSibling;
                do 1 === v.nodeType && v.tagName === c.tagName && m++,
                v = v.previousSibling;
                while (v)
            }
            d[h++] = c.tagName + (m > 1 ? m: ""),
            c = c.parentNode
        }
        if (i !== o && (p = o.getAttribute("data-click"), p && (n = e.extend(t(p), n))), l) return ! l;
        d.reverse();
        var b = i.tagName.toLowerCase();
        return ! s && /^a|img|input|button|select|datalist|textarea$/.test(b) && (s = {
            a: "link"
        } [b] || "input", u = i.href || i.src || u),
        (s = i.getAttribute("data-type") || s) ? (u && (n.url = u), a(n, i, "p1"), a(n, i, "act"), a(n, i, "item"), a(n, i, "mod", o.id), r(n, i, s, b, d, h), n.xpath = d.join("-").toLowerCase() + "(" + s + ")", n) : !1
    },
    r = function(t, n, i, r, a, o) {
        var s = "";
        if ("input" === i) if (/input|textarea/.test(r)) s = n.value,
        n.type && "password" === n.type.toLowerCase() && (s = "");
        else if (/select|datalist/.test(r)) {
            if (n.children.length > 0) {
                var u = n.selectedIndex || 0;
                s = n.children[u > -1 ? u: 0].innerHTML
            }
        } else s = n.innerHTML || n.value || "";
        else if ("img" === r && (s = n.title), !s) {
            el = n;
            for (var l = o; l > 0;) {
                if (l--, /^a\d*\b/i.test(a[l])) {
                    url = el.href,
                    s = el.innerHTML;
                    break
                }
                if (el.className && /\bOP_LOG_[A-Z]+\b/.test(el.className)) {
                    s = el.innerHTML;
                    break
                }
                el = el.parentNode
            }
        }
        t.txt = e.trim(s)
    },
    a = function(e, t, n, i) {
        e[n] = t.getAttribute("data-" + n) || e[n] || i || "-"
    },
    o = {
        action: "http://nsclick.baidu.com/v.gif?",
        main: "result-op",
        title: "OP_LOG_TITLE",
        link: "OP_LOG_LINK",
        img: "OP_LOG_IMG",
        btn: "OP_LOG_BTN",
        input: "OP_LOG_INPUT",
        others: "OP_LOG_OTHERS",
        data: {
            url: location.href,
            pid: "-",
            cat: "-",
            page: "-",
            fr: "-",
            pvid: "-",
            rqid: "-",
            qid: "-",
            psid: "-",
            sid: "-",
            pn: "-",
            act: "-",
            mod: "-",
            item: "-",
            p1: "-",
            xpath: "-",
            f: "-",
            txt: "-",
            q: "-",
            rsv: null
        }
    },
    s = function(n, i) {
        var r = t(n.getAttribute("data-click"));
        r.p1 = i,
        n.setAttribute("data-click", e.stringify(r))
    },
    u = function(r, a) {
        var u = a || e.getTarget(r),
        l = o.main,
        c = e.hasClass(u, l) ? u: e.getAncestorByClass(u, l);
        if (c && "1" !== c.getAttribute("data-nolog")) {
            var d = u.getAttribute("data-click");
            d && (d = t(d)),
            d = i(d || {},
            u, c),
            d && (o.data && (d = e.extend(e.extend({},
            o.data), d)), "p1" in d || e.each(e.q(o.main),
            function(e, t) {
                e === c && (d.p1 = t + 1),
                s(e, t + 1)
            }), exports.fire("click", {
                data: d,
                target: u,
                main: c
            }), n(d))
        }
    },
    exports = {
        config: function(t) {
            return e.extend(o, t),
            this
        },
        start: function() {
            return e.on(document, "mousedown", u),
            this.fire("start"),
            this
        },
        stop: function() {
            return e.un(document, "mousedown", u),
            this
        },
        click: function(e) {
            return u(null, e),
            this
        },
        fill: function(n, i) {
            for (var r, a, o = 0; r = n[o++];) a = r.getAttribute("data-click"),
            a && (i = e.extend(t(a), i)),
            r.setAttribute("data-click", e.stringify(i));
            return this
        },
        live: function(t) {
            var n = this.map;
            return n || (n = this.map = {},
            this.on("click",
            function(e) {
                var t = e.data.mod;
                t && t in n && n[t](e)
            })),
            e.extend(n, t),
            this
        },
        send: function(t) {
            return n(e.extend(e.clone(o.data), t)),
            this
        }
    };
    return e.extend(exports, e.clone(e.observable)),
    exports
}),
define("common/config",
function() {
    return {
        HUNTER_FOR_COURSE: {
            "éæå¹è®­": "24025",
            "è±è¯­å¹è®­": "24026",
            "ç¾æ¯å¹è®­": "24027",
            "æç¦å¹è®­": "24028",
            "åµå¥å¼å¹è®­": "24029",
            "æ¥è¯­å¹è®­": "24030",
            "JAVAå¹è®­": "24031",
            "IOSå¹è®­": "24032",
            "å»ºé å¸å¹è®­": "24033",
            "å¬å¡åå¹è®­": "24034",
            "ä¼è®¡å¹è®­": "24035",
            "æå½±å¹è®­": "24036"
        },
        HUNTER_FOR_EXAM: {
            "éæèè¯": "36505",
            "å¤§å­¦è±è¯­å­çº§èè¯": "36506",
            "å¤§å­¦è±è¯­åçº§èè¯": "36507",
            "æç¦èè¯": "36508",
            "ä¼è®¡ä»ä¸èµæ ¼èè¯": "36509",
            "æ³¨åä¼è®¡å¸èè¯": "36510",
            "å½å®¶å¬å¡åèè¯": "36511",
            "ä¸­å­¦æå¸èµæ ¼è¯èè¯": "36512",
            "èç§°è±è¯­èè¯": "36513",
            "è¯å¸ä»ä¸èµæ ¼èè¯": "36514"
        },
        HUNTER_FOR_ORG: {
            "é©¾æ ¡": "26717",
            "è±è¯­å¹è®­å­¦æ ¡": "26718",
            "åå¦å­¦æ ¡": "26719",
            "æ±½ä¿®å­¦æ ¡": "26720",
            "å¹³é¢è®¾è®¡å¹è®­å­¦æ ¡": "26721",
            "æ­¦æ¯å­¦æ ¡": "26722",
            "èè¹å­¦æ ¡": "26723",
            "å® ç©ç¾å®¹å­¦æ ¡": "26724",
            "æå½±å­¦æ ¡": "26725",
            "ç¾å®¹ç¾åå­¦æ ¡": "26726"
        }
    }
}),
define("common/log",
function(require) {
    {
        var e = require("./data"),
        t = require("../lib/zxui/log");
        require("./config")
    }
    t.config({
        rd_action: require.toUrl("img/w") + ".gif?",
        action: "http://nsclick.baidu.com/v.gif?",
        data: {
            logType: "edu",
            page: "edu-result",
            pid: "364",
            cat: "juhe",
            sid: e.get("sid"),
            subqid: e.get("subqid"),
            queryStr: e.get("originQuery"),
            pn: e.get("page"),
            pvid: e.get("pvid")
        }
    }),
    t.start();
    var n;
    return {
        getBodyClickData: function() {
            var t = {
                logType: "edu",
                page: "edu-result",
                pid: "364",
                cat: "juhe",
                sid: e.get("sid"),
                subqid: e.get("subqid"),
                queryStr: e.get("originQuery"),
                pn: e.get("page"),
                pvid: e.get("pvid")
            };
            return t
        },
        updateBodyClickData: function(e) {
            var t = e || this.getBodyClickData();
            t = $.toJSON(t),
            $("body").attr("data-click", t)
        },
        initLog: function() {
            var n = (new Date).getTime().toString(36);
            e.set("pvid", n);
            var i = this.getBodyClickData();
            this.updateBodyClickData(i),
            i.act = "pv",
            i.url = location.href,
            t.send(i)
        },
        initAnti: function(e) {
            e = e || document.body,
            n = new Anti(e),
            n.bind(),
            this.updateSigntime()
        },
        updateSigntime: function() {
            var t = e.get("signtime");
            n.setTimesign(t)
        },
        initHunter: function(e, t) {
            if (("function" != typeof t || t() === !0) && e) {
                var n = window.Hunter || {};
                n.userConfig = n.userConfig || [],
                n.userConfig.push({
                    hid: e
                });
                var i = "http://img.baidu.com/hunter/ECOM.js?st=" + ~ (new Date / 864e5);
                $.getScript(i)
            }
        },
        submitHeaderForm: function() {
            var e = {
                act: "pv",
                f: 1
            };
            t.send(e)
        }
    }
}),
define("lib/er/Observable",
function(require) {
    function e() {
        this._events = {}
    }
    var t = "_erObservableGUID";
    return e.prototype.on = function(e, n) {
        this._events || (this._events = {});
        var i = this._events[e];
        i || (i = this._events[e] = []),
        n.hasOwnProperty(t) || (n[t] = require("./util").guid()),
        i.push(n)
    },
    e.prototype.un = function(e, t) {
        if (this._events) {
            if (!t) return void(this._events[e] = []);
            var n = this._events[e];
            if (n) for (var i = 0; i < n.length; i++) n[i] === t && (n.splice(i, 1), i--)
        }
    },
    e.prototype.fire = function(e, n) {
        1 === arguments.length && "object" == typeof e && (n = e, e = n.type);
        var i = this["on" + e];
        if ("function" == typeof i && i.call(this, n), this._events) {
            null == n && (n = {}),
            "[object Object]" !== Object.prototype.toString.call(n) && (n = {
                data: n
            }),
            n.type = e,
            n.target = this;
            var r = {},
            a = this._events[e];
            if (a) {
                a = a.slice();
                for (var o = 0; o < a.length; o++) {
                    var s = a[o];
                    r.hasOwnProperty(s[t]) || s.call(this, n)
                }
            }
            if ("*" !== e) {
                var u = this._events["*"];
                if (!u) return;
                u = u.slice();
                for (var o = 0; o < u.length; o++) {
                    var s = u[o];
                    r.hasOwnProperty(s[t]) || s.call(this, n)
                }
            }
        }
    },
    e.enable = function(t) {
        t._events = {},
        t.on = e.prototype.on,
        t.un = e.prototype.un,
        t.fire = e.prototype.fire
    },
    e
}),
define("lib/underscore/underscore",
function(require, exports, module) { (function() {
        var e = this,
        t = e._,
        n = {},
        i = Array.prototype,
        r = Object.prototype,
        a = Function.prototype,
        o = i.push,
        s = i.slice,
        u = i.concat,
        l = r.toString,
        c = r.hasOwnProperty,
        d = i.forEach,
        f = i.map,
        p = i.reduce,
        h = i.reduceRight,
        g = i.filter,
        m = i.every,
        v = i.some,
        b = i.indexOf,
        y = i.lastIndexOf,
        x = Array.isArray,
        w = Object.keys,
        T = a.bind,
        E = function(e) {
            return e instanceof E ? e: this instanceof E ? void(this._wrapped = e) : new E(e)
        };
        "undefined" != typeof exports ? ("undefined" != typeof module && module.exports && (exports = module.exports = E), exports._ = E) : e._ = E,
        E.VERSION = "1.4.4";
        var C = E.each = E.forEach = function(e, t, i) {
            if (null != e) if (d && e.forEach === d) e.forEach(t, i);
            else if (e.length === +e.length) {
                for (var r = 0,
                a = e.length; a > r; r++) if (t.call(i, e[r], r, e) === n) return
            } else for (var o in e) if (E.has(e, o) && t.call(i, e[o], o, e) === n) return
        };
        E.map = E.collect = function(e, t, n) {
            var i = [];
            return null == e ? i: f && e.map === f ? e.map(t, n) : (C(e,
            function(e, r, a) {
                i[i.length] = t.call(n, e, r, a)
            }), i)
        };
        var S = "Reduce of empty array with no initial value";
        E.reduce = E.foldl = E.inject = function(e, t, n, i) {
            var r = arguments.length > 2;
            if (null == e && (e = []), p && e.reduce === p) return i && (t = E.bind(t, i)),
            r ? e.reduce(t, n) : e.reduce(t);
            if (C(e,
            function(e, a, o) {
                r ? n = t.call(i, n, e, a, o) : (n = e, r = !0)
            }), !r) throw new TypeError(S);
            return n
        },
        E.reduceRight = E.foldr = function(e, t, n, i) {
            var r = arguments.length > 2;
            if (null == e && (e = []), h && e.reduceRight === h) return i && (t = E.bind(t, i)),
            r ? e.reduceRight(t, n) : e.reduceRight(t);
            var a = e.length;
            if (a !== +a) {
                var o = E.keys(e);
                a = o.length
            }
            if (C(e,
            function(s, u, l) {
                u = o ? o[--a] : --a,
                r ? n = t.call(i, n, e[u], u, l) : (n = e[u], r = !0)
            }), !r) throw new TypeError(S);
            return n
        },
        E.find = E.detect = function(e, t, n) {
            var i;
            return k(e,
            function(e, r, a) {
                return t.call(n, e, r, a) ? (i = e, !0) : void 0
            }),
            i
        },
        E.filter = E.select = function(e, t, n) {
            var i = [];
            return null == e ? i: g && e.filter === g ? e.filter(t, n) : (C(e,
            function(e, r, a) {
                t.call(n, e, r, a) && (i[i.length] = e)
            }), i)
        },
        E.reject = function(e, t, n) {
            return E.filter(e,
            function(e, i, r) {
                return ! t.call(n, e, i, r)
            },
            n)
        },
        E.every = E.all = function(e, t, i) {
            t || (t = E.identity);
            var r = !0;
            return null == e ? r: m && e.every === m ? e.every(t, i) : (C(e,
            function(e, a, o) {
                return (r = r && t.call(i, e, a, o)) ? void 0 : n
            }), !!r)
        };
        var k = E.some = E.any = function(e, t, i) {
            t || (t = E.identity);
            var r = !1;
            return null == e ? r: v && e.some === v ? e.some(t, i) : (C(e,
            function(e, a, o) {
                return r || (r = t.call(i, e, a, o)) ? n: void 0
            }), !!r)
        };
        E.contains = E.include = function(e, t) {
            return null == e ? !1 : b && e.indexOf === b ? -1 != e.indexOf(t) : k(e,
            function(e) {
                return e === t
            })
        },
        E.invoke = function(e, t) {
            var n = s.call(arguments, 2),
            i = E.isFunction(t);
            return E.map(e,
            function(e) {
                return (i ? t: e[t]).apply(e, n)
            })
        },
        E.pluck = function(e, t) {
            return E.map(e,
            function(e) {
                return e[t]
            })
        },
        E.where = function(e, t, n) {
            return E.isEmpty(t) ? n ? null: [] : E[n ? "find": "filter"](e,
            function(e) {
                for (var n in t) if (t[n] !== e[n]) return ! 1;
                return ! 0
            })
        },
        E.findWhere = function(e, t) {
            return E.where(e, t, !0)
        },
        E.max = function(e, t, n) {
            if (!t && E.isArray(e) && e[0] === +e[0] && e.length < 65535) return Math.max.apply(Math, e);
            if (!t && E.isEmpty(e)) return - 1 / 0;
            var i = {
                computed: -1 / 0,
                value: -1 / 0
            };
            return C(e,
            function(e, r, a) {
                var o = t ? t.call(n, e, r, a) : e;
                o >= i.computed && (i = {
                    value: e,
                    computed: o
                })
            }),
            i.value
        },
        E.min = function(e, t, n) {
            if (!t && E.isArray(e) && e[0] === +e[0] && e.length < 65535) return Math.min.apply(Math, e);
            if (!t && E.isEmpty(e)) return 1 / 0;
            var i = {
                computed: 1 / 0,
                value: 1 / 0
            };
            return C(e,
            function(e, r, a) {
                var o = t ? t.call(n, e, r, a) : e;
                o < i.computed && (i = {
                    value: e,
                    computed: o
                })
            }),
            i.value
        },
        E.shuffle = function(e) {
            var t, n = 0,
            i = [];
            return C(e,
            function(e) {
                t = E.random(n++),
                i[n - 1] = i[t],
                i[t] = e
            }),
            i
        };
        var _ = function(e) {
            return E.isFunction(e) ? e: function(t) {
                return t[e]
            }
        };
        E.sortBy = function(e, t, n) {
            var i = _(t);
            return E.pluck(E.map(e,
            function(e, t, r) {
                return {
                    value: e,
                    index: t,
                    criteria: i.call(n, e, t, r)
                }
            }).sort(function(e, t) {
                var n = e.criteria,
                i = t.criteria;
                if (n !== i) {
                    if (n > i || void 0 === n) return 1;
                    if (i > n || void 0 === i) return - 1
                }
                return e.index < t.index ? -1 : 1
            }), "value")
        };
        var O = function(e, t, n, i) {
            var r = {},
            a = _(t || E.identity);
            return C(e,
            function(t, o) {
                var s = a.call(n, t, o, e);
                i(r, s, t)
            }),
            r
        };
        E.groupBy = function(e, t, n) {
            return O(e, t, n,
            function(e, t, n) { (E.has(e, t) ? e[t] : e[t] = []).push(n)
            })
        },
        E.countBy = function(e, t, n) {
            return O(e, t, n,
            function(e, t) {
                E.has(e, t) || (e[t] = 0),
                e[t]++
            })
        },
        E.sortedIndex = function(e, t, n, i) {
            n = null == n ? E.identity: _(n);
            for (var r = n.call(i, t), a = 0, o = e.length; o > a;) {
                var s = a + o >>> 1;
                n.call(i, e[s]) < r ? a = s + 1 : o = s
            }
            return a
        },
        E.toArray = function(e) {
            return e ? E.isArray(e) ? s.call(e) : e.length === +e.length ? E.map(e, E.identity) : E.values(e) : []
        },
        E.size = function(e) {
            return null == e ? 0 : e.length === +e.length ? e.length: E.keys(e).length
        },
        E.first = E.head = E.take = function(e, t, n) {
            return null == e ? void 0 : null == t || n ? e[0] : s.call(e, 0, t)
        },
        E.initial = function(e, t, n) {
            return s.call(e, 0, e.length - (null == t || n ? 1 : t))
        },
        E.last = function(e, t, n) {
            return null == e ? void 0 : null == t || n ? e[e.length - 1] : s.call(e, Math.max(e.length - t, 0))
        },
        E.rest = E.tail = E.drop = function(e, t, n) {
            return s.call(e, null == t || n ? 1 : t)
        },
        E.compact = function(e) {
            return E.filter(e, E.identity)
        };
        var A = function(e, t, n) {
            return C(e,
            function(e) {
                E.isArray(e) ? t ? o.apply(n, e) : A(e, t, n) : n.push(e)
            }),
            n
        };
        E.flatten = function(e, t) {
            return A(e, t, [])
        },
        E.without = function(e) {
            return E.difference(e, s.call(arguments, 1))
        },
        E.uniq = E.unique = function(e, t, n, i) {
            E.isFunction(t) && (i = n, n = t, t = !1);
            var r = n ? E.map(e, n, i) : e,
            a = [],
            o = [];
            return C(r,
            function(n, i) { (t ? i && o[o.length - 1] === n: E.contains(o, n)) || (o.push(n), a.push(e[i]))
            }),
            a
        },
        E.union = function() {
            return E.uniq(u.apply(i, arguments))
        },
        E.intersection = function(e) {
            var t = s.call(arguments, 1);
            return E.filter(E.uniq(e),
            function(e) {
                return E.every(t,
                function(t) {
                    return E.indexOf(t, e) >= 0
                })
            })
        },
        E.difference = function(e) {
            var t = u.apply(i, s.call(arguments, 1));
            return E.filter(e,
            function(e) {
                return ! E.contains(t, e)
            })
        },
        E.zip = function() {
            for (var e = s.call(arguments), t = E.max(E.pluck(e, "length")), n = new Array(t), i = 0; t > i; i++) n[i] = E.pluck(e, "" + i);
            return n
        },
        E.object = function(e, t) {
            if (null == e) return {};
            for (var n = {},
            i = 0,
            r = e.length; r > i; i++) t ? n[e[i]] = t[i] : n[e[i][0]] = e[i][1];
            return n
        },
        E.indexOf = function(e, t, n) {
            if (null == e) return - 1;
            var i = 0,
            r = e.length;
            if (n) {
                if ("number" != typeof n) return i = E.sortedIndex(e, t),
                e[i] === t ? i: -1;
                i = 0 > n ? Math.max(0, r + n) : n
            }
            if (b && e.indexOf === b) return e.indexOf(t, n);
            for (; r > i; i++) if (e[i] === t) return i;
            return - 1
        },
        E.lastIndexOf = function(e, t, n) {
            if (null == e) return - 1;
            var i = null != n;
            if (y && e.lastIndexOf === y) return i ? e.lastIndexOf(t, n) : e.lastIndexOf(t);
            for (var r = i ? n: e.length; r--;) if (e[r] === t) return r;
            return - 1
        },
        E.range = function(e, t, n) {
            arguments.length <= 1 && (t = e || 0, e = 0),
            n = arguments[2] || 1;
            for (var i = Math.max(Math.ceil((t - e) / n), 0), r = 0, a = new Array(i); i > r;) a[r++] = e,
            e += n;
            return a
        },
        E.bind = function(e, t) {
            if (e.bind === T && T) return T.apply(e, s.call(arguments, 1));
            var n = s.call(arguments, 2);
            return function() {
                return e.apply(t, n.concat(s.call(arguments)))
            }
        },
        E.partial = function(e) {
            var t = s.call(arguments, 1);
            return function() {
                return e.apply(this, t.concat(s.call(arguments)))
            }
        },
        E.bindAll = function(e) {
            var t = s.call(arguments, 1);
            return 0 === t.length && (t = E.functions(e)),
            C(t,
            function(t) {
                e[t] = E.bind(e[t], e)
            }),
            e
        },
        E.memoize = function(e, t) {
            var n = {};
            return t || (t = E.identity),
            function() {
                var i = t.apply(this, arguments);
                return E.has(n, i) ? n[i] : n[i] = e.apply(this, arguments)
            }
        },
        E.delay = function(e, t) {
            var n = s.call(arguments, 2);
            return setTimeout(function() {
                return e.apply(null, n)
            },
            t)
        },
        E.defer = function(e) {
            return E.delay.apply(E, [e, 1].concat(s.call(arguments, 1)))
        },
        E.throttle = function(e, t) {
            var n, i, r, a, o = 0,
            s = function() {
                o = new Date,
                r = null,
                a = e.apply(n, i)
            };
            return function() {
                var u = new Date,
                l = t - (u - o);
                return n = this,
                i = arguments,
                0 >= l ? (clearTimeout(r), r = null, o = u, a = e.apply(n, i)) : r || (r = setTimeout(s, l)),
                a
            }
        },
        E.debounce = function(e, t, n) {
            var i, r;
            return function() {
                var a = this,
                o = arguments,
                s = function() {
                    i = null,
                    n || (r = e.apply(a, o))
                },
                u = n && !i;
                return clearTimeout(i),
                i = setTimeout(s, t),
                u && (r = e.apply(a, o)),
                r
            }
        },
        E.once = function(e) {
            var t, n = !1;
            return function() {
                return n ? t: (n = !0, t = e.apply(this, arguments), e = null, t)
            }
        },
        E.wrap = function(e, t) {
            return function() {
                var n = [e];
                return o.apply(n, arguments),
                t.apply(this, n)
            }
        },
        E.compose = function() {
            var e = arguments;
            return function() {
                for (var t = arguments,
                n = e.length - 1; n >= 0; n--) t = [e[n].apply(this, t)];
                return t[0]
            }
        },
        E.after = function(e, t) {
            return 0 >= e ? t() : function() {
                return--e < 1 ? t.apply(this, arguments) : void 0
            }
        },
        E.keys = w ||
        function(e) {
            if (e !== Object(e)) throw new TypeError("Invalid object");
            var t = [];
            for (var n in e) E.has(e, n) && (t[t.length] = n);
            return t
        },
        E.values = function(e) {
            var t = [];
            for (var n in e) E.has(e, n) && t.push(e[n]);
            return t
        },
        E.pairs = function(e) {
            var t = [];
            for (var n in e) E.has(e, n) && t.push([n, e[n]]);
            return t
        },
        E.invert = function(e) {
            var t = {};
            for (var n in e) E.has(e, n) && (t[e[n]] = n);
            return t
        },
        E.functions = E.methods = function(e) {
            var t = [];
            for (var n in e) E.isFunction(e[n]) && t.push(n);
            return t.sort()
        },
        E.extend = function(e) {
            return C(s.call(arguments, 1),
            function(t) {
                if (t) for (var n in t) e[n] = t[n]
            }),
            e
        },
        E.pick = function(e) {
            var t = {},
            n = u.apply(i, s.call(arguments, 1));
            return C(n,
            function(n) {
                n in e && (t[n] = e[n])
            }),
            t
        },
        E.omit = function(e) {
            var t = {},
            n = u.apply(i, s.call(arguments, 1));
            for (var r in e) E.contains(n, r) || (t[r] = e[r]);
            return t
        },
        E.defaults = function(e) {
            return C(s.call(arguments, 1),
            function(t) {
                if (t) for (var n in t) null == e[n] && (e[n] = t[n])
            }),
            e
        },
        E.clone = function(e) {
            return E.isObject(e) ? E.isArray(e) ? e.slice() : E.extend({},
            e) : e
        },
        E.tap = function(e, t) {
            return t(e),
            e
        };
        var N = function(e, t, n, i) {
            if (e === t) return 0 !== e || 1 / e == 1 / t;
            if (null == e || null == t) return e === t;
            e instanceof E && (e = e._wrapped),
            t instanceof E && (t = t._wrapped);
            var r = l.call(e);
            if (r != l.call(t)) return ! 1;
            switch (r) {
            case "[object String]":
                return e == String(t);
            case "[object Number]":
                return e != +e ? t != +t: 0 == e ? 1 / e == 1 / t: e == +t;
            case "[object Date]":
            case "[object Boolean]":
                return + e == +t;
            case "[object RegExp]":
                return e.source == t.source && e.global == t.global && e.multiline == t.multiline && e.ignoreCase == t.ignoreCase
            }
            if ("object" != typeof e || "object" != typeof t) return ! 1;
            for (var a = n.length; a--;) if (n[a] == e) return i[a] == t;
            n.push(e),
            i.push(t);
            var o = 0,
            s = !0;
            if ("[object Array]" == r) {
                if (o = e.length, s = o == t.length) for (; o--&&(s = N(e[o], t[o], n, i)););
            } else {
                var u = e.constructor,
                c = t.constructor;
                if (u !== c && !(E.isFunction(u) && u instanceof u && E.isFunction(c) && c instanceof c)) return ! 1;
                for (var d in e) if (E.has(e, d) && (o++, !(s = E.has(t, d) && N(e[d], t[d], n, i)))) break;
                if (s) {
                    for (d in t) if (E.has(t, d) && !o--) break;
                    s = !o
                }
            }
            return n.pop(),
            i.pop(),
            s
        };
        E.isEqual = function(e, t) {
            return N(e, t, [], [])
        },
        E.isEmpty = function(e) {
            if (null == e) return ! 0;
            if (E.isArray(e) || E.isString(e)) return 0 === e.length;
            for (var t in e) if (E.has(e, t)) return ! 1;
            return ! 0
        },
        E.isElement = function(e) {
            return ! (!e || 1 !== e.nodeType)
        },
        E.isArray = x ||
        function(e) {
            return "[object Array]" == l.call(e)
        },
        E.isObject = function(e) {
            return e === Object(e)
        },
        C(["Arguments", "Function", "String", "Number", "Date", "RegExp"],
        function(e) {
            E["is" + e] = function(t) {
                return l.call(t) == "[object " + e + "]"
            }
        }),
        E.isArguments(arguments) || (E.isArguments = function(e) {
            return ! (!e || !E.has(e, "callee"))
        }),
        "function" != typeof / . / &&(E.isFunction = function(e) {
            return "function" == typeof e
        }),
        E.isFinite = function(e) {
            return isFinite(e) && !isNaN(parseFloat(e))
        },
        E.isNaN = function(e) {
            return E.isNumber(e) && e != +e
        },
        E.isBoolean = function(e) {
            return e === !0 || e === !1 || "[object Boolean]" == l.call(e)
        },
        E.isNull = function(e) {
            return null === e
        },
        E.isUndefined = function(e) {
            return void 0 === e
        },
        E.has = function(e, t) {
            return c.call(e, t)
        },
        E.noConflict = function() {
            return e._ = t,
            this
        },
        E.identity = function(e) {
            return e
        },
        E.times = function(e, t, n) {
            for (var i = Array(e), r = 0; e > r; r++) i[r] = t.call(n, r);
            return i
        },
        E.random = function(e, t) {
            return null == t && (t = e, e = 0),
            e + Math.floor(Math.random() * (t - e + 1))
        };
        var P = {
            escape: {
                "&": "&amp;",
                "<": "&lt;",
                ">": "&gt;",
                '"': "&quot;",
                "'": "&#x27;",
                "/": "&#x2F;"
            }
        };
        P.unescape = E.invert(P.escape);
        var L = {
            escape: new RegExp("[" + E.keys(P.escape).join("") + "]", "g"),
            unescape: new RegExp("(" + E.keys(P.unescape).join("|") + ")", "g")
        };
        E.each(["escape", "unescape"],
        function(e) {
            E[e] = function(t) {
                return null == t ? "": ("" + t).replace(L[e],
                function(t) {
                    return P[e][t]
                })
            }
        }),
        E.result = function(e, t) {
            if (null == e) return null;
            var n = e[t];
            return E.isFunction(n) ? n.call(e) : n
        },
        E.mixin = function(e) {
            C(E.functions(e),
            function(t) {
                var n = E[t] = e[t];
                E.prototype[t] = function() {
                    var e = [this._wrapped];
                    return o.apply(e, arguments),
                    D.call(this, n.apply(E, e))
                }
            })
        };
        var j = 0;
        E.uniqueId = function(e) {
            var t = ++j + "";
            return e ? e + t: t
        },
        E.templateSettings = {
            evaluate: /<%([\s\S]+?)%>/g,
            interpolate: /<%=([\s\S]+?)%>/g,
            escape: /<%-([\s\S]+?)%>/g
        };
        var R = /(.)^/,
        $ = {
            "'": "'",
            "\\": "\\",
            "\r": "r",
            "\n": "n",
            "	": "t",
            "\u2028": "u2028",
            "\u2029": "u2029"
        },
        M = /\\|'|\r|\n|\t|\u2028|\u2029/g;
        E.template = function(e, t, n) {
            var i;
            n = E.defaults({},
            n, E.templateSettings);
            var r = new RegExp([(n.escape || R).source, (n.interpolate || R).source, (n.evaluate || R).source].join("|") + "|$", "g"),
            a = 0,
            o = "__p+='";
            e.replace(r,
            function(t, n, i, r, s) {
                return o += e.slice(a, s).replace(M,
                function(e) {
                    return "\\" + $[e]
                }),
                n && (o += "'+\n((__t=(" + n + "))==null?'':_.escape(__t))+\n'"),
                i && (o += "'+\n((__t=(" + i + "))==null?'':__t)+\n'"),
                r && (o += "';\n" + r + "\n__p+='"),
                a = s + t.length,
                t
            }),
            o += "';\n",
            n.variable || (o = "with(obj||{}){\n" + o + "}\n"),
            o = "var __t,__p='',__j=Array.prototype.join,print=function(){__p+=__j.call(arguments,'');};\n" + o + "return __p;\n";
            try {
                i = new Function(n.variable || "obj", "_", o)
            } catch(s) {
                throw s.source = o,
                s
            }
            if (t) return i(t, E);
            var u = function(e) {
                return i.call(this, e, E)
            };
            return u.source = "function(" + (n.variable || "obj") + "){\n" + o + "}",
            u
        },
        E.chain = function(e) {
            return E(e).chain()
        };
        var D = function(e) {
            return this._chain ? E(e).chain() : e
        };
        E.mixin(E),
        C(["pop", "push", "reverse", "shift", "sort", "splice", "unshift"],
        function(e) {
            var t = i[e];
            E.prototype[e] = function() {
                var n = this._wrapped;
                return t.apply(n, arguments),
                "shift" != e && "splice" != e || 0 !== n.length || delete n[0],
                D.call(this, n)
            }
        }),
        C(["concat", "join", "slice"],
        function(e) {
            var t = i[e];
            E.prototype[e] = function() {
                return D.call(this, t.apply(this._wrapped, arguments))
            }
        }),
        E.extend(E.prototype, {
            chain: function() {
                return this._chain = !0,
                this
            },
            value: function() {
                return this._wrapped
            }
        })
    }).call(this)
}),
define("common/widget/Layer",
function() {
    function e(e, t, n) {
        $(e).on(t, n)
    }
    function t(e, t, n) {
        $(e).off(t, n)
    }
    function n(e, t) {
        return e === t ? !0 : $.contains(e, t)
    }
    function i(e, t) {
        return $(e).css(t)
    }
    function r(t) {
        if ("click" === t.showBy) e(t.trigger, "click",
        function() {
            t.isHidden() && t.show()
        });
        else {
            var n;
            e(t.trigger, "mouseover",
            function() {
                n || (n = setTimeout(function() {
                    n && t.isHidden() && (n = null, t.show())
                },
                100))
            }),
            e(t.trigger, "mouseout",
            function() {
                n && (clearTimeout(n), n = null)
            })
        }
    }
    function a(i) {
        function r(e) {
            n(i.main, e.target) || i.hide()
        }
        function a(e) {
            u = setTimeout(function() {
                if (u) {
                    var t = e.relatedTarget;
                    n(i.trigger, t) || n(i.main, t) || i.hide()
                }
            },
            500)
        }
        function o() {
            u && (clearTimeout(u), u = null)
        }
        function s() { - 1 !== i.hideBy.indexOf("blur") && t(document, "click", r),
            -1 !== i.hideBy.indexOf("out") && (t(i.trigger, "mouseout", a), t(i.trigger, "mouseover", o), t(i.main, "mouseout", a), t(i.main, "mouseover", o))
        }
        var u; - 1 !== i.hideBy.indexOf("blur") && setTimeout(function() {
            i.isHidden() || e(document, "click", r)
        },
        150),
        -1 !== i.hideBy.indexOf("out") && (e(i.trigger, "mouseout", a), e(i.trigger, "mouseover", o), e(i.main, "mouseout", a), e(i.main, "mouseover", o)),
        i.onbeforehide = function() {
            s()
        }
    }
    function o(e) {
        for (var t in e) this[t] = e[t];
        r(this)
    }
    return o.prototype = {
        constructor: o,
        show: function() {
            this.main.style.display = "block",
            "function" == typeof this.onshow && this.onshow(),
            a(this)
        },
        hide: function() {
            "function" == typeof this.onbeforehide && this.onbeforehide(),
            this.main.style.display = "none",
            "function" == typeof this.onhide && this.onhide()
        },
        isHidden: function() {
            return "none" === i(this.main, "display")
        },
        on: function(t, n) {
            e(this.main, t, n)
        },
        off: function(e, n) {
            t(this.main, e, n)
        }
    },
    o
}),
define("common/widget/City",
function(require) {
    function e() {
        for (var e = [], t = 0, n = arguments.length; n > t; t++) {
            var i = arguments[t];
            if ($.isArray(i)) for (var r = 0,
            a = i.length; a > r; r++) e.push(i[r])
        }
        return e
    }
    function t(e, t) {
        return $.inArray(e, t)
    }
    function n(e, t) {
        return $(e).attr(t)
    }
    function i(e, t) {
        return $("." + e, t)
    }
    function r(e, t) {
        $(e).addClass(t)
    }
    function a(e, t) {
        $(e).removeClass(t)
    }
    function o(e, t) {
        return '<a href="#" title="' + t + '" hidefocus="true" data-click=\'{"action":"change-city", "cityid":"' + e + '", "cityname":"' + t + '"}\' data-city-id="' + e + '">' + t + "</a>"
    }
    function s(e, t) {
        var n = [];
        n.push(t ? '<ul data-target="' + t + '">': "<ul>");
        for (var i, r = 0,
        a = e.length; a > r; r++) i = e[r],
        n.push((r + 1) % E === 0 ? '<li class="' + y + '">': "<li>"),
        n.push(o(i.id, i.text)),
        n.push("</li>");
        return n.push("</ul>"),
        n.join("")
    }
    function u(e, t, n) {
        var i = [g];
        e && i.push(e);
        var r = ['<div class="'];
        return r.push(i.join(" ")),
        r.push('">'),
        t && (r.push("<strong>"), r.push(t), r.push("</strong>")),
        r.push(n),
        r.push("</div>"),
        r.join("")
    }
    function l() {
        for (var e = ["<ul>"], t = 0, n = C.length; n > t; t++) e.push('<li><a href="#" data-tab="'),
        e.push(C[t]),
        e.push('">'),
        e.push(C[t]),
        e.push("</a></li>");
        return e.join("")
    }
    function c(t) {
        for (var n = [], i = p.all_cities, r = 0, a = t.length; a > r; r++) {
            var o = t.charAt(r);
            n.push(i[o])
        }
        return n = e.apply(null, n),
        s(n, t)
    }
    function d() {
        var e = u(x, "å½åå°åºï¼", o(p.cur_city.id, p.cur_city.text));
        e += u(w, "ç­é¨åå¸", s(p.hot_cities));
        var t = ['<div class="' + m + '">'];
        t.push(l()),
        t.push("</div>"),
        t.push('<div class="' + v + '">');
        for (var n = 0,
        i = C.length; i > n; n++) t.push(c(C[n]));
        return t.push("</div>"),
        e += u(T, "å¨é¨åå¸", t.join("")),
        e += '<span class="layer-tail"></span>'
    }
    function f(e) {
        this.layer = new h({
            trigger: e.trigger,
            main: e.layer,
            showBy: "click",
            hideBy: "blur"
        }),
        p = e.datasource,
        this.layer.main.innerHTML = d(),
        this.switchTab(C[0]);
        var t = this;
        this.layer.on("click",
        function(e) {
            var i = e.target;
            if ("A" === i.tagName) {
                var r = n(i, "data-tab");
                if (r) t.switchTab(r);
                else {
                    var a = n(i, "data-city-id");
                    if (a) {
                        var o = i.innerHTML;
                        t.switchCity(a, o)
                    }
                }
            }
            return "close-btn" === i.className && t.layer.hide(),
            !1
        })
    }
    var p, h = require("./Layer"),
    g = "city-category",
    m = "city-nav-tab",
    v = "city-tab-content",
    b = "city-active",
    y = "city-offside",
    x = "cur-city",
    w = "hot-city",
    T = "all-city",
    E = 8,
    C = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "W", "X", "Y", "Z"];
    return f.prototype = {
        constructor: f,
        switchTab: function(e) {
            var n = t(e, C);
            if ( - 1 !== n && n !== this.activeTab) {
                var o = this.layer.main,
                s = i(m, o)[0],
                u = s.getElementsByTagName("a");
                s = i(v, o)[0];
                var l = s.getElementsByTagName("ul");
                null != this.activeTab && (a(u[this.activeTab], b), a(l[this.activeTab], b)),
                r(u[n], b),
                r(l[n], b),
                this.activeTab = n
            }
        },
        switchCity: function(e, t) {
            this.selectCity(e),
            "function" == typeof this.oncitychange && this.oncitychange({
                cityId: e,
                cityName: t
            })
        },
        selectCity: function(e) {
            for (var t = this.layer.main.getElementsByTagName("a"), i = this.activeCity, o = 0, s = t.length; s > o; o++) {
                var u = n(t[o], "data-city-id");
                u && u == e && r(t[o], b),
                i && u == i && a(t[o], b)
            }
            this.activeCity = e
        }
    },
    f
}),
define("common/redirect",
function(require) {
    function e(e, t) {
        var n = {};
        t && $.extend(e, t);
        var i = o.getStore("commonParams");
        for (var r in i)"key" != r && (e[r] = i[r]);
        e.originQuery === o.get("searchInputPlaceholder") && (e.originQuery = null);
        var a;
        for (var r in e) a = e[r],
        null != a && "" !== a && (n[r] = a);
        return n
    }
    function t(e, t) {
        var n = $.param(t);
        return n && (e += "?" + n),
        e
    }
    function n(e, t, n, i) {
        var r = '<form action="' + e + '"';
        n && (r += ' target="_blank"'),
        i && (r += ' accept-charset="' + i + '" onsubmit="document.charset="' + i + '";"'),
        r += ">";
        for (var a in t) r += '<input type="hidden" name="' + a + '" value="' + t[a] + '" />';
        return r += "</form>",
        $(r)
    }
    function i(e, i, r, a) {
        var o;
        if (o = 0 === e.indexOf("http") ? e: u + e, r) {
            var s = n(o, i, r, a);
            s.appendTo(document.body),
            s[0].submit()
        } else window.location.href = t(o, i)
    }
    function r() {
        var e = $("#search-input").prop("value");
        return $.trim(e)
    }
    var a = require("../lib/er/URL"),
    o = require("./data"),
    s = window.location,
    u = s.protocol + "//" + s.host;
    return {
        toCourse: function(t, n, a) {
            var s = n || "/query/juhe",
            u = {
                originQuery: r() || o.get("originQuery"),
                key: r() || o.get("originQuery"),
                city: o.get("city"),
                cityid: o.get("cityid"),
                fenlei: o.get("fenlei"),
                uiSid: o.get("uiSid"),
                sessionID: o.get("sessionID")
            },
            l = o.get("tags");
            l && l.length > 0 && (u.tags = l.join(",")),
            u = e(u, t),
            i(s, u, a)
        },
        toCourseIndex: function(t, n, r) {
            var a = n || "/mp/course",
            s = {
                city: o.get("city"),
                cityid: o.get("cityid"),
                fenlei: o.get("fenlei"),
                uiSid: o.get("uiSid")
            };
            s = e(s, t),
            i(a, s, r)
        },
        toOrgIndex: function(t, n, r) {
            var a = n || "/mp/org",
            s = {
                city: o.get("city"),
                cityid: o.get("cityid"),
                fenlei: o.get("fenlei"),
                uiSid: o.get("uiSid")
            };
            s = e(s, t),
            i(a, s, r)
        },
        toAbroad: function(t, n, r) {
            var a = n || "/query/abroad",
            s = {
                city: o.get("city"),
                cityid: o.get("cityid"),
                fenlei: o.get("fenlei"),
                uiSid: o.get("uiSid")
            };
            s = e(s, t),
            i(a, s, r)
        },
        toExamIndex: function(t, n, r) {
            var a = n || "/mp/exam",
            s = {
                city: o.get("city"),
                cityid: o.get("cityid"),
                fenlei: o.get("fenlei"),
                uiSid: o.get("uiSid")
            };
            s = e(s, t),
            i(a, s, r)
        },
        toExam: function(t, n, r) {
            var a = n || "/query/exam",
            s = {
                city: o.get("city"),
                cityid: o.get("cityid"),
                fenlei: o.get("fenlei"),
                uiSid: o.get("uiSid")
            };
            s = e(s, t),
            i(a, s, r)
        },
        toIndex: function(t, n, r) {
            var a = n || "/mp/index",
            s = e({
                originQuery: "",
                key: "",
                fenlei: o.get("fenlei"),
                uiSid: o.get("uiSid")
            },
            t);
            i(a, s, r)
        },
        toWenku: function(t, n, r) {
            var a = n || "/mp/wenku",
            s = e({
                city: o.get("city"),
                cityid: o.get("cityid"),
                fenlei: o.get("fenlei"),
                uiSid: o.get("uiSid")
            },
            t);
            i(a, s, r)
        },
        toOrg: function(t, n, a) {
            var s = n || "/query/orgjuhe",
            u = {
                originQuery: r() || o.get("originQuery"),
                key: r() || o.get("originQuery"),
                city: o.get("city"),
                cityid: o.get("cityid"),
                fenlei: o.get("fenlei"),
                uiSid: o.get("uiSid"),
                sessionID: o.get("sessionID")
            },
            l = o.get("tags");
            l && l.length > 0 && (u.tags = l.join(",")),
            u = e(u, t),
            i(s, u, a)
        },
        toShequ: function(t, n, r) {
            var a = n || "/mp/shequ",
            s = e({
                city: o.get("city"),
                cityid: o.get("cityid"),
                fenlei: o.get("fenlei"),
                uiSid: o.get("uiSid")
            },
            t);
            s = e(s, t),
            i(a, s, r)
        },
        toDxt: function(t, n, a) {
            var s = n || "/xuetang",
            u = e({
                originQuery: r() || o.get("originQuery")
            },
            t);
            i(s, u, a)
        },
        searchWenku: function(e, t) {
            i("http://wenku.baidu.com/search", {
                word: e
            },
            t, "gbk")
        },
        addParams: function(e, n) {
            var i, r, o = e.href,
            s = o.indexOf("?"); - 1 !== s ? (i = o.substr(0, s), r = a.parseQuery(o.substr(s + 1))) : (i = o, r = {}),
            $.extend(r, n),
            e.href = t(i, r)
        }
    }
}),
define("common/inputSugg",
function() {
    function e(e, t) {
        return t = t || {},
        e.replace(/\$\{(.+?)\}/g,
        function(e, n) {
            return void 0 === t[n] ? "": t[n]
        })
    }
    function t(e) {
        function t() {
            d && (window.clearTimeout(d), d = null),
            d = window.setTimeout(u, y)
        }
        f = $("#search-input"),
        p = $("#header-recwords"),
        h = $("#moduleType"),
        g = $("#fenlei"),
        T ? s(t) : f.bind("input", t),
        f.bind("focus", t),
        f.bind("blur", o),
        p.delegate("li", "click",
        function(t) {
            var n = $(t.currentTarget).html();
            "function" == typeof e && e(n)
        }).delegate("li", "mouseover", n),
        f.bind("keypress", r).bind("keydown", a)
    }
    function n() {
        m ? (m.removeClass("liSelected"), m = $(this)) : m = $(this),
        m.addClass("liSelected")
    }
    function i(e) {
        x = 38 != e.which && 40 != e.which && 13 != e.which ? !1 : !0
    }
    function r(e) {
        w && (i(e), 13 == e.which && (m ? m.trigger("click") : (l(), submitForm())))
    }
    function a(e) {
        w && (i(e), 38 == e.which && (m ? (m.removeClass("liSelected"), m = m.prev("li"), 0 == m.length && (m = null)) : m = p.find("li:last"), m && m.addClass("liSelected")), 40 == e.which && (m ? (m.removeClass("liSelected"), m = m.next("li"), 0 == m.length && (m = null)) : m = p.find("li:first"), m && m.addClass("liSelected")), (40 == e.which || 38 == e.which) && (f.val(m ? m.text() : v), e.preventDefault()))
    }
    function o() {
        b && (window.clearTimeout(b), b = null),
        b = window.setTimeout(l, 270)
    }
    function s(e) {
        var t, n = f.val();
        f.bind("focus",
        function() {
            t = window.setInterval(function() {
                var t = f.val();
                t != n && (n = t, e())
            },
            30)
        }),
        f.bind("blur",
        function() {
            window.clearInterval(t),
            t = null
        })
    }
    function u() {
        if (!x) {
            if (/^\s*$/.test(f.val())) return void l();
            v = $.trim(f.val()),
            c(encodeURIComponent($.trim(f.val())))
        }
    }
    function l() {
        p.hide(),
        window.clearTimeout(d),
        d = null,
        w = !1,
        x = !1,
        m = null
    }
    function c(t) {
        function n(t) {
            if (!t || !t.length) return void l();
            for (var n = "",
            r = 0,
            a = t.length; a > r; r++) n += e(i, t[r]);
            p.html(n).css("display", "block"),
            w = !0
        }
        var i = "<li>${word}</li>",
        r = {
            query: t
        };
        h.length > 0 && (r.moduleType = h.val()),
        g.length > 0 && (r.fenlei = g.val()),
        "findforyou" != r.moduleType && $.ajax({
            type: "get",
            async: !1,
            url: "http://hui.baidu.com/api/suggestion.php?trade=edu&query=" + t,
            dataType: "jsonp",
            jsonp: "callback",
            jsonpCallback: "suggestion",
            success: function(e) {
                0 == e.status ? n(e.data) : l()
            },
            error: function() {}
        })
    }
    var d, f, p, h, g, m, v, b, y = 200,
    x = !1,
    w = !1,
    T = /msie (\d+\.\d)/i.test(navigator.userAgent);
    return {
        initRecWords: t,
        isRecShow: w
    }
}),
define("common/header",
function(require, exports) {
    function e() {
        var e = $("#city-button"),
        t = $("#city-layer"),
        n = $("#city-icon"),
        a = "/util/city";
        $.post(a,
        function(a) {
            "string" == typeof a && (a = $.parseJSON(a)),
            a.cur_city = {
                id: r.get("ipcityid"),
                text: r.get("ipcity")
            };
            var o = new i({
                trigger: e[0],
                layer: t[0],
                datasource: a
            });
            o.layer.onshow = function() {
                n.addClass("hover")
            },
            o.layer.onhide = function() {
                n.removeClass("hover")
            },
            o.oncitychange = function(e) {
                o.layer.hide();
                var t = e.cityId,
                n = e.cityName,
                i = $("#city-text");
                i.data("city-id", t),
                i.html(n),
                r.set({
                    page: 1,
                    city: n,
                    cityid: t,
                    tags: [],
                    citychange: 1
                }),
                exports.fire({
                    type: "citychange"
                })
            };
            var s = r.get("curcityid");
            s && o.selectCity(s)
        })
    }
    function t() {
        function e(e) {
            var n = $.trim(t.val());
            if (n) {
                if (n == r.get("searchInputPlaceholder")) return void t.val("");
                a.submitHeaderForm(e),
                r.set("originQuery", n),
                r.set({
                    cityid: null,
                    city: null,
                    tags: []
                }),
                exports.submitForm()
            }
        }
        var t = $("#search-input"),
        n = $("#search-button"),
        i = r.get("searchInputPlaceholder");
        t.prop("placeholder", i),
        n.click(function(t) {
            e(t.target)
        }),
        t.keyup(function(t) {
            13 === t.keyCode && e(t.target)
        })
    }
    var n = require("../lib/er/Observable"),
    i = (require("../lib/underscore/underscore"), require("./widget/City")),
    r = (require("./widget/Layer"), require("./data")),
    a = require("./log"),
    o = require("./redirect"),
    s = require("./inputSugg");
    n.enable(exports),
    exports.init = function(n) {
        e(),
        t(),
        void 0 != n && s.initRecWords(n)
    },
    exports.submitForm = function() {
        o.toCourse()
    }
}),
define("common/menu",
function(require) {
    var e = require("./redirect");
    return {
        init: function() {
            var t = $("#nav .menu");
            t.on("click", ".menu-name",
            function(t) {
                var n = $(t.currentTarget);
                switch (n.data("name")) {
                case "index":
                    e.toIndex(null, null, !1);
                    break;
                case "course":
                    e.toCourseIndex(null, null, !1);
                    break;
                case "org":
                    e.toOrgIndex(null, null, !1);
                    break;
                case "wenku":
                    e.toWenku(null, null, !1);
                    break;
                case "abroad":
                    e.toAbroad(null, null, !1);
                    break;
                case "exam":
                    e.toExamIndex(null, null, !1);
                    break;
                case "dxt":
                    e.toDxt(null, null, !1);
                    break;
                case "shequ":
                    e.toShequ(null, null, !1)
                }
                return ! 1
            })
        }
    }
}),
define("lib/zxui/Control",
function(require) {
    var e = require("./lib"),
    t = e.newClass({
        type: "Control",
        disabled: !1,
        bindEvents: function(t) {
            var n = this;
            t && t.length && ("string" == typeof t && (t = t.split(/\s*,\s*/)), e.each(t,
            function(t, i) {
                i = t && n[t],
                i && (n[t] = e.bind(i, n))
            }))
        },
        initialize: function(e) {
            e = this.setOptions(e),
            this.binds && this.bindEvents(this.binds),
            this.init && this.init(e),
            this.children = []
        },
        render: function() {
            throw new Error("not implement render")
        },
        appendTo: function(e) {
            this.main = e || this.main,
            this.render()
        },
        query: function(t) {
            return e.q(t, this.main)
        },
        disable: function() {
            this.disabled = !0,
            this.fire("disable")
        },
        enable: function() {
            this.disabled = !1,
            this.fire("enable")
        },
        isDisabled: function() {
            return this.disabled
        },
        addChild: function(e, t) {
            var n = this.children;
            t = t || e.childName,
            t && (n[nane] = e),
            n.push(e)
        },
        removeChild: function(e) {
            var t = this.children;
            for (var n in t) t.hasOwnProperty(n) && t[n] === e && delete this[n]
        },
        getChild: function(e) {
            return this.children[e]
        },
        initChildren: function() {
            throw new Error("not implement initChildren")
        },
        dispose: function() {
            this.fire("dispose");
            for (var e; e = this.children.pop();) e.dispose();
            for (var t in this._listners) this.un(t)
        }
    }).implement(e.observable).implement(e.configurable);
    return t
}),
define("lib/zxui/Pager",
function(require) {
    var e = require("./lib"),
    t = require("./Control"),
    n = t.extend({
        type: "Pager",
        options: {
            disabled: !1,
            main: "",
            page: 0,
            padding: 1,
            showAlways: !0,
            showCount: 0,
            total: 0,
            prefix: "ecl-ui-pager",
            disabledClass: "disabled",
            lang: {
                prev: "<em></em>ä¸ä¸é¡µ",
                next: "ä¸ä¸é¡µ<em></em>",
                ellipsis: ".."
            }
        },
        binds: "onChange",
        init: function(t) {
            this.disabled = t.disabled,
            this.showCount = t.showCount || n.SHOW_COUNT,
            this.total = t.total,
            this.padding = t.padding,
            this.page = 0,
            this.setPage(0 | t.page);
            var i = t.lang;
            i.prev.replace(/\{prefix\}/gi, t.prefix),
            i.next.replace(/\{prefix\}/gi, t.prefix),
            t.main && (this.main = e.g(t.main), e.addClass(this.main, t.prefix), e.on(this.main, "click", this.onChange))
        },
        setPage: function(e) {
            e = Math.max(0, Math.min(0 | e, this.total - 1)),
            e !== this.page && (this.page = e)
        },
        getPage: function() {
            return this.page
        },
        setTotal: function(e) {
            this.total = 0 | e || 1,
            this.setPage(0)
        },
        getTotal: function() {
            return this.total
        },
        render: function() {
            if (!this.main) throw new Error("invalid main");
            var t = this.main;
            return this.total > 1 || this.options.showAlways ? (t.innerHTML = this.build(), e.show(t)) : e.hide(t),
            this
        },
        build: function() {
            function e(e) {
                c[d++] = '<a href="#" data-page="' + (e - 1) + '">' + e + "</a>"
            }
            function t(e, t, n) {
                var a = r + t;
                n && (a += " " + r + "disabled"),
                c[d++] = '<a href="#" data-page="' + e + '" class="' + a + '">' + (i[t] || e + 1) + "</a>"
            }
            var n = this.options,
            i = n.lang,
            r = n.prefix + "-",
            a = n.showAlways,
            o = this.showCount,
            s = this.total,
            u = this.page + 1,
            l = this.padding,
            c = [],
            d = 0;
            if (2 > s) return a && (t(0, "prev", !0), t(0, "current"), t(0, "next", !0)),
            c.join("");
            var f = 1,
            p = s,
            h = (o - o % 2) / 2;
            for (o = 2 * h + 1, s > o && (p = o, u > h + 1 && (u + h > s ? (f = s - 2 * h, p = s) : (f = u - h, p = u + h))), (u > 1 || a) && t(u - 2, "prev", 2 > u), m = 0; l > m; m++) f > m + 1 && e(m + 1);
            f > l + 2 && t(u - 2, "ellipsis"),
            f === l + 2 && e(l + 1);
            for (var g = u,
            m = f; p >= m; m++) m === g ? t(m - 1, "current") : e(m);
            var v = s - l;
            for (v - 1 > p && t(u, "ellipsis"), p === v - 1 && e(v), m = 0; l > m; m++) v + m + 1 > p && e(v + m + 1);
            return (s > u || a) && t(u, "next", u >= s),
            c.join("")
        },
        onChange: function(t, n) {
            t && e.preventDefault(t),
            n = n || e.getTarget(t),
            this.fire("click");
            var i = this.main;
            if (!this.disabled && n && n !== i && ("A" === n.tagName || (n = e.getAncestorBy(n,
            function(e) {
                return "A" === e.tagName || e === i
            }), n !== i))) {
                var r = n.getAttribute("data-page");
                null !== r && (r |= 0);
                var a = this.page;
                null !== r && r >= 0 && r < this.total && r !== a && this.fire("change", {
                    page: r
                })
            }
        }
    });
    return n.SHOW_COUNT = 5,
    n
}),
define("common/pager",
function(require, exports) {
    var e, t = require("../lib/er/Observable"),
    n = require("../lib/zxui/Pager"),
    i = require("./data"),
    r = (require("./log"), {
        showAlways: !1,
        prefix: "edu-pager",
        lang: {
            prev: "<i><< </i>ä¸ä¸é¡µ",
            next: "ä¸ä¸é¡µ<i> >></i>",
            ellipsis: "..."
        }
    });
    t.enable(exports),
    exports.init = function(t) {
        var a = {},
        o = $(t.main);
        o.attr("data-click", '{"mod":"pager"}'),
        $.extend(a, {
            main: o[0],
            page: t.page - 1,
            total: t.totalPage
        },
        r),
        e = new n(a),
        e.render(),
        0 == t.totalPage && o.hide(),
        o.on("click", "a",
        function(e) {
            var t = $(e.currentTarget);
            if (!t.hasClass(r.prefix + "-current") && !t.hasClass(r.prefix + "-ellipsis")) {
                var n = t.data("page") + 1;
                exports.fire({
                    type: "change",
                    page: n
                }),
                i.set("page", n),
                window.location.hash = "",
                window.location.hash = "#result-start"
            }
        })
    },
    exports.refresh = function(t, n) {
        e.setTotal(n),
        e.setPage(t - 1),
        e.render()
    }
}),
define("common/tip",
function(require) {
    function e() {
        t.init({
            triggers: {
                renzheng: "icon-vcard",
                "coupon.edu": "c-text-warning"
            }
        })
    }
    var t = require("pszx/tip")($);
    return {
        initTips: e
    }
}),
define("lib/er/assert",
function() {
    if (window.DEBUG) {
        var e = function(e, t) {
            if (!e) throw new Error(t)
        };
        return e.has = function(t, n) {
            e(null != t, n)
        },
        e.equals = function(t, n, i) {
            e(t === n, i)
        },
        e.hasProperty = function(t, n, i) {
            e(null != t[n], i)
        },
        e.lessThan = function(t, n, i) {
            e(n > t, i)
        },
        e.greaterThan = function(t, n, i) {
            e(t > max, i)
        },
        e.lessThanOrEquals = function(t, n, i) {
            e(n >= t, i)
        },
        e.greaterThanOrEquals = function(t, n, i) {
            e(t >= max, i)
        },
        e
    }
    var e = function() {};
    return e.has = e,
    e.equals = e,
    e.hasProperty = e,
    e.lessThan = e,
    e.greaterThan = e,
    e.lessThanOrEquals = e,
    e.greaterThanOrEquals = e,
    e
}),
define("lib/er/Deferred",
function(require) {
    function e(e) {
        function t() {
            for (var t = 0; t < n.length; t++) {
                var i = n[t];
                try {
                    i.apply(e.promise, e._args)
                } catch(r) {}
            }
        }
        if ("pending" !== e.state) {
            var n = "resolved" === e.state ? e._doneCallbacks.slice() : e._failCallbacks.slice();
            e.syncModeEnabled ? t() : a(t),
            e._doneCallbacks = [],
            e._failCallbacks = []
        }
    }
    function t(e, t, i, r) {
        return function() {
            if ("function" == typeof i) {
                var a = t.resolver;
                try {
                    var o = i.apply(e.promise, arguments);
                    n.isPromise(o) ? o.then(a.resolve, a.reject) : a.resolve(o)
                } catch(s) {
                    a.reject(s)
                }
            } else t[r].apply(t, e._args)
        }
    }
    function n() {
        this.state = "pending",
        this._args = null,
        this._doneCallbacks = [],
        this._failCallbacks = [],
        this.promise = {
            done: i.bind(this.done, this),
            fail: i.bind(this.fail, this),
            ensure: i.bind(this.ensure, this),
            then: i.bind(this.then, this)
        },
        this.promise.promise = this.promise,
        this.resolver = {
            resolve: i.bind(this.resolve, this),
            reject: i.bind(this.reject, this)
        }
    }
    var i = require("./util"),
    r = require("./assert"),
    a = "function" == typeof window.setImmediate ?
    function(e) {
        window.setImmediate(e)
    }: function(e) {
        window.setTimeout(e, 0)
    };
    return n.isPromise = function(e) {
        return e && "function" == typeof e.then
    },
    n.prototype.syncModeEnabled = !1,
    n.prototype.resolve = function() {
        "pending" === this.state && (this.state = "resolved", this._args = [].slice.call(arguments), e(this))
    },
    n.prototype.reject = function() {
        "pending" === this.state && (this.state = "rejected", this._args = [].slice.call(arguments), e(this))
    },
    n.prototype.done = function(e) {
        return this.then(e)
    },
    n.prototype.fail = function(e) {
        return this.then(null, e)
    },
    n.prototype.ensure = function(e) {
        return this.then(e, e)
    },
    n.prototype.then = function(i, r) {
        var a = new n;
        return a.syncModeEnabled = this.syncModeEnabled,
        this._doneCallbacks.push(t(this, a, i, "resolve")),
        this._failCallbacks.push(t(this, a, r, "reject")),
        e(this),
        a.promise
    },
    n.all = function() {
        function e(e) {
            o--,
            r.greaterThanOrEquals(o, 0, "workingCount should be positive");
            var t = [].slice.call(arguments, 1);
            t.length <= 1 && (t = t[0]),
            u[e] = t,
            0 === o && l[s].apply(l, u)
        }
        function t() {
            s = "reject",
            e.apply(this, arguments)
        }
        for (var a = [].concat.apply([], arguments), o = a.length, s = "resolve", u = [], l = new n, c = 0; c < a.length; c++) {
            var d = a[c];
            d.then(i.bind(e, d, c), i.bind(t, d, c))
        }
        return l.promise
    },
    n.resolved = function() {
        var e = new n;
        return e.resolve.apply(e, arguments),
        e.promise
    },
    n.rejected = function() {
        var e = new n;
        return e.reject.apply(e, arguments),
        e.promise
    },
    n
}),
define("lib/er/Model",
function(require) {
    function e(e, t) {
        function n(n) {
            t.dump ? e.fill(n, l) : e.set(t.name, n, l)
        }
        var i = t.retrieve(e);
        return u.isPromise(i) ? ("function" == typeof i.abort && e.addPendingWorker(i), i.done(n), i) : (n(i), u.resolved())
    }
    function t(e, t) {
        for (var n = u.resolved(), r = 0; r < t.length; r++) {
            var a = t[r],
            o = s.bind(i, null, e, a);
            n = n.done(o)
        }
        return n
    }
    function n(e, t) {
        var n = [];
        for (var r in t) if (t.hasOwnProperty(r)) {
            var a = t[r];
            "function" == typeof a ? a = {
                retrieve: a,
                name: r
            }: "function" == typeof a.retrieve && (a = s.mix({
                name: r
            },
            a)),
            n.push(i(e, a))
        }
        return u.all(n)
    }
    function i(i, r) {
        if (!r) return u.resolved();
        if ("function" == typeof r) {
            var a = {
                retrieve: r,
                dump: !0
            };
            return e(i, a)
        }
        return r instanceof Array ? t(i, r) : "function" == typeof r.retrieve ? e(i, r) : n(i, r)
    }
    function r(e) {
        this.store = {},
        this.pendingWorkers = [],
        e && this.fill(e, l)
    }
    function a(e, t) {
        for (var n = 0; n < e.pendingWorkers.length; n++) if (e.pendingWorkers[n] === t) return void e.pendingWorkers.splice(n, 1)
    }
    function o(e, t, n) {
        var i = e.store.hasOwnProperty(t) ? "change": "add",
        r = e.store[t];
        return e.store[t] = n,
        r !== n ? {
            type: i,
            name: t,
            oldValue: r,
            newValue: n
        }: null
    }
    var s = require("./util"),
    u = require("./Deferred"),
    l = {
        silent: !0
    },
    c = require("./Observable");
    return r.prototype.addPendingWorker = function(e) {
        this.pendingWorkers.push(e),
        e.ensure(s.bind(a, null, this, e))
    },
    r.prototype.datasource = null,
    r.prototype.load = function() {
        try {
            var e = i(this, this.datasource);
            return e.done(s.bind(this.prepare, this))
        } catch(t) {
            return u.rejected(t)
        }
    },
    r.prototype.prepare = function() {},
    r.prototype.get = function(e) {
        return this.store[e]
    },
    r.prototype.set = function(e, t, n) {
        n = n || {};
        var i = o(this, e, t);
        if (i && !n.silent) {
            var r = {
                changes: [i]
            };
            this.fire("change", r)
        }
    },
    r.prototype.fill = function(e, t) {
        t = t || {};
        var n = [];
        for (var i in e) if (e.hasOwnProperty(i)) {
            var r = o(this, i, e[i]);
            r && n.push(r)
        }
        if (n.length && !t.silent) {
            var a = {
                changes: n
            };
            this.fire("change", a)
        }
    },
    r.prototype.remove = function(e, t) {
        if (this.store.hasOwnProperty(e)) {
            t = t || {};
            var n = this.store[e];
            if (delete this.store[e], !t.silent) {
                var i = {
                    changes: [{
                        type: "remove",
                        name: e,
                        oldValue: n,
                        newValue: void 0
                    }]
                };
                this.fire("change", i)
            }
            return n
        }
    },
    r.prototype.getAsModel = function(e) {
        var t = this.get(e);
        return t && "[object Object]" === {}.toString.call(t) ? new r(t) : new r
    },
    r.prototype.valueOf = function() {
        return s.mix({},
        this.store)
    },
    r.prototype.clone = function() {
        return new r(this.store)
    },
    r.prototype.dispose = function() {
        for (var e = 0; e < this.pendingWorkers.length; e++) {
            var t = this.pendingWorkers[e];
            if ("function" == typeof t.abort) try {
                t.abort()
            } catch(n) {}
        }
        this.pendingWorkers = null
    },
    s.inherits(r, c),
    r
}),
define("lib/er/template",
function(require) {
    function Stack() {
        this.container = [],
        this.index = -1
    }
    function ArrayBuffer() {
        this.raw = [],
        this.idx = 0
    }
    function NodeIterator(e) {
        this.stream = e,
        this.index = 0
    }
    function Scope(e) {
        this._store = {},
        this.parent = e
    }
    function nodeAnalyse(e) {
        function t() {
            v.push({
                type: TYPE.TEXT,
                text: m.join("")
            }),
            m = new ArrayBuffer
        }
        function n(e, t) {
            throw e + " is invalid: " + t
        }
        function i(e) {
            m.pushMore(h, e, g)
        }
        var r, a, o, s, u, l, c, d, f, p, h = "<!--",
        g = "-->",
        m = new ArrayBuffer,
        v = new ArrayBuffer,
        b = e.split(h);
        for ("" === b[0] && b.shift(), r = 0, a = b.length; a > r; r++) if (o = b[r].split(g), s = o.length, 2 === s || r > 0) if (2 === s) {
            if (u = o[0], COMMENT_RULE.test(u)) if (t(), l = RegExp.$2.toLowerCase(), c = RegExp.$3, d = {
                type: TYPE[l.toUpperCase()]
            },
            RegExp.$1) d.endTag = 1,
            v.push(d);
            else {
                switch (l) {
                case "content":
                case "contentplaceholder":
                case "master":
                case "import":
                case "target":
                    if (TAG_RULE.test(c)) for (d.id = RegExp.$1, f = RegExp.$2.split(/\s*,\s*/), p = f.length; p--;) {
                        var y = f[p];
                        PROP_RULE.test(y) && (d[RegExp.$1] = RegExp.$2)
                    } else n(l, u);
                    break;
                case "for":
                    FOR_RULE.test(c) ? (d.list = RegExp.$1, d.item = RegExp.$2, d.index = RegExp.$4) : n(l, u);
                    break;
                case "if":
                case "elif":
                    IF_RULE.test(RegExp.$3) ? d.expr = condExpr.parse(RegExp.$1) : n(l, u);
                    break;
                case "else":
                    break;
                default:
                    d = null,
                    i(u)
                }
                d && v.push(d)
            } else i(u);
            m.push(o[1])
        } else m.push(o[0]);
        return t(),
        v.getRaw()
    }
    function getVariableValue(e, t, n) {
        t = t.split(/[\.\[]/);
        var i = e.get(t[0]);
        t.shift();
        for (var r = 0,
        a = t.length; a > r && null != i; r++) {
            var o = t[r].replace(/\]$/, ""),
            s = o.length;
            /^(['"])/.test(o) && o.lastIndexOf(RegExp.$1) === --s && (o = o.slice(1, s)),
            i = i[o]
        }
        var u = "";
        null != i && (u = i);
        var l = filterContainer[n || "html"];
        return l && (u = l(u)),
        u
    }
    function getContent(e) {
        var t, n, i, r = e.block,
        a = [];
        for (n = 0, i = r.length; i > n; n++) t = r[n],
        a.push(t.block ? getContent(t) : t.type === TYPE.IMPORT ? getTargetContent(t.id) : t.text || "");
        return a.join("")
    }
    function getTargetContent(e) {
        try {
            var t = getTarget(e);
            return getContent(t) || ""
        } catch(n) {
            return ""
        }
    }
    function getTarget(e) {
        var t = targetContainer[e];
        if (!t) throw 'target "' + e + '" is not exist!';
        if (t.type !== TYPE.TARGET) throw 'target "' + e + '" is invalid!';
        return t
    }
    function replaceVariable(e, t) {
        return e.replace(/\$\{([.a-z0-9\[\]'"_]+)\s*(\|([a-z]+))?\s*\}/gi,
        function(e, n, i, r) {
            return getVariableValue(t, n, r)
        })
    }
    function execImport(e, t) {
        var n = getTarget(e.id);
        return exec(n, t)
    }
    function exec(e, t) {
        var n, i, r, a, o, s, u, l, c, d, f = [],
        p = e.block;
        for (i = 0, r = p.length; r > i; i++) switch (n = p[i], n.type) {
        case TYPE.TEXT:
            f.push(replaceVariable(n.text, t));
            break;
        case TYPE.IMPORT:
            f.push(execImport(n, t));
            break;
        case TYPE.FOR:
            for (a = new Scope(t), o = t.get(n.list), l = n.item, c = n.index, s = 0, u = o.length; u > s; s++) a.set(l, o[s]),
            c && a.set(c, s),
            f.push(exec(n, a));
            break;
        case TYPE.IF:
            for (d = condExpr.exec(n.expr, t); ! d && (n = n["else"]);) d = !n.expr || condExpr.exec(n.expr, t);
            n && f.push(exec(n, t))
        }
        return f.join("")
    }
    function parse(e) {
        var t = nodeAnalyse(e);
        syntaxAnalyse(t)
    }
    function merge(e, t, n) {
        var i, r = "";
        if (e) {
            try {
                i = getTarget(t),
                r = exec(i, new Scope(n))
            } catch(a) {}
            e.innerHTML = r
        }
    }
    var util = require("./util");
    Stack.prototype = {
        current: function() {
            return this.container[this.index]
        },
        push: function(e) {
            this.container[++this.index] = e
        },
        pop: function() {
            if (this.index < 0) return null;
            var e = this.container[this.index];
            return this.container.length = this.index--,
            e
        },
        bottom: function() {
            return this.container[0]
        }
    },
    ArrayBuffer.prototype = {
        push: function(e) {
            this.raw[this.idx++] = e
        },
        pushMore: function() {
            for (var e = 0,
            t = arguments.length; t > e; e++) this.push(arguments[e])
        },
        join: function(e) {
            return this.raw.join(e)
        },
        getRaw: function() {
            return this.raw
        }
    },
    NodeIterator.prototype = {
        next: function() {
            return this.stream[++this.index]
        },
        prev: function() {
            return this.stream[--this.index]
        },
        current: function() {
            return this.stream[this.index]
        }
    },
    Scope.prototype = {
        get: function(e) {
            var t = this._store[e];
            return null == t && this.parent ? this.parent.get(e) : null != t ? t: null
        },
        set: function(e, t) {
            this._store[e] = t
        }
    };
    var TYPE = {
        TEXT: 1,
        TARGET: 2,
        MASTER: 3,
        IMPORT: 4,
        CONTENT: 5,
        CONTENTPLACEHOLDER: 6,
        FOR: 7,
        IF: 8,
        ELIF: 9,
        ELSE: 10
    },
    COMMENT_RULE = /^\s*(\/)?([a-z]+)(.*)$/i,
    PROP_RULE = /^\s*([0-9a-z_]+)\s*=\s*([0-9a-z_]+)\s*$/i,
    FOR_RULE = /^\s*:\s*\$\{([0-9a-z_.\[\]]+)\}\s+as\s+\$\{([0-9a-z_]+)\}\s*(,\s*\$\{([0-9a-z_]+)\})?\s*$/i,
    IF_RULE = /^\s*:([>=<!0-9a-z$\{\}\[\]\(\):\s'"\.\|&_]+)\s*$/i,
    TAG_RULE = /^\s*:\s*([a-z0-9_]+)\s*(?:\(([^)]+)\))?\s*$/i,
    CONDEXPR_RULE = /\s*(\!=?=?|\|\||&&|>=?|<=?|===?|['"\(\)]|\$\{[^\}]+\}|\-?[0-9]+(\.[0-9]+)?)/,
    masterContainer = {},
    targetContainer = {},
    filterContainer = {
        html: util.encodeHTML,
        url: encodeURIComponent
    },
    syntaxAnalyse = function() {
        function e(e) {
            for (var t; (t = o.current()) && t.type !== e;) o.pop();
            return o.pop()
        }
        function t(e) {
            o.push(e)
        }
        function n() {
            var e = o.bottom;
            return "[er template]" + e.type + " " + e.id + ": unexpect " + s.current().type + " on " + o.current().type
        }
        function i(e) {
            var t = u[e];
            t && t()
        }
        var r, a, o, s, u = {};
        return u[TYPE.TARGET] = function() {
            var a = s.current();
            for (a.block = [], a.content = {},
            t(a), r[a.id] = a; a = s.next();) switch (a.type) {
            case TYPE.TARGET:
            case TYPE.MASTER:
                return e(),
                void(a.endTag || s.prev());
            case TYPE.CONTENTPLACEHOLDER:
            case TYPE.
                ELSE:
            case TYPE.ELIF:
                throw n();
            default:
                i(a.type)
            }
        },
        u[TYPE.MASTER] = function() {
            var r = s.current();
            for (r.block = [], t(r), a[r.id] = r; r = s.next();) switch (r.type) {
            case TYPE.TARGET:
            case TYPE.MASTER:
                return e(),
                void(r.endTag || s.prev());
            case TYPE.CONTENT:
            case TYPE.
                ELSE:
            case TYPE.ELIF:
                throw n();
            default:
                i(r.type)
            }
        },
        u[TYPE.TEXT] = u[TYPE.IMPORT] = u[TYPE.CONTENTPLACEHOLDER] = function() {
            o.current().block.push(s.current())
        },
        u[TYPE.CONTENT] = function() {
            var r = s.current();
            for (r.block = [], o.bottom().content[r.id] = r, t(r); r = s.next();) {
                if (r.endTag) return void(r.type === TYPE.CONTENT ? e(TYPE.CONTENT) : s.prev());
                switch (r.type) {
                case TYPE.TARGET:
                case TYPE.MASTER:
                    return e(),
                    void s.prev();
                case TYPE.CONTENTPLACEHOLDER:
                case TYPE.
                    ELSE:
                case TYPE.ELIF:
                    throw n();
                case TYPE.CONTENT:
                    return e(TYPE.CONTENT),
                    void s.prev();
                default:
                    i(r.type)
                }
            }
        },
        u[TYPE.FOR] = function() {
            var r = s.current();
            for (r.block = [], o.current().block.push(r), t(r); r = s.next();) {
                if (r.endTag) return void(r.type === TYPE.FOR ? e(TYPE.FOR) : s.prev());
                switch (r.type) {
                case TYPE.TARGET:
                case TYPE.MASTER:
                    return e(),
                    void s.prev();
                case TYPE.CONTENTPLACEHOLDER:
                case TYPE.CONTENT:
                case TYPE.
                    ELSE:
                case TYPE.ELIF:
                    throw n();
                default:
                    i(r.type)
                }
            }
        },
        u[TYPE.IF] = function() {
            var r = s.current();
            for (r.block = [], o.current().block.push(r), t(r); r = s.next();) {
                if (r.endTag) return void(r.type === TYPE.IF ? e(TYPE.IF) : s.prev());
                switch (r.type) {
                case TYPE.TARGET:
                case TYPE.MASTER:
                    return e(),
                    void s.prev();
                case TYPE.CONTENTPLACEHOLDER:
                case TYPE.CONTENT:
                    throw n();
                default:
                    i(r.type)
                }
            }
        },
        u[TYPE.ELIF] = function() {
            var r = s.current();
            for (r.type = TYPE.IF, r.block = [], e(TYPE.IF)["else"] = r, t(r); r = s.next();) {
                if (r.endTag) return void s.prev();
                switch (r.type) {
                case TYPE.TARGET:
                case TYPE.MASTER:
                    return e(),
                    void s.prev();
                case TYPE.CONTENTPLACEHOLDER:
                case TYPE.CONTENT:
                    throw n();
                case TYPE.ELIF:
                    return void s.prev();
                default:
                    i(r.type)
                }
            }
        },
        u[TYPE.
        ELSE] = function() {
            for (var r, a = s.current(), u = o.current();;) {
                if (r = u.type, r === TYPE.IF || r === TYPE.ELIF) {
                    u = {
                        type: TYPE.
                        ELSE,
                        block: []
                    },
                    o.current()["else"] = u;
                    break
                }
                u = o.pop()
            }
            for (t(u); a = s.next();) {
                if (a.endTag) return void s.prev();
                switch (a.type) {
                case TYPE.TARGET:
                case TYPE.MASTER:
                    return e(),
                    void s.prev();
                case TYPE.CONTENTPLACEHOLDER:
                case TYPE.CONTENT:
                case TYPE.
                    ELSE:
                case TYPE.ELIF:
                    throw n();
                default:
                    i(a.type)
                }
            }
        },
        function(e) {
            var t, n, i, l, c, d, f, p, h, g;
            for (s = new NodeIterator(e), r = {},
            a = {},
            o = new Stack; t = s.current();) switch (t.type) {
            case TYPE.TARGET:
            case TYPE.MASTER:
                u[t.type]();
                break;
            default:
                s.next()
            }
            for (n in a) {
                if (masterContainer[n]) throw 'master "' + n + '" is exist!';
                masterContainer[n] = a[n]
            }
            for (n in r) {
                if (targetContainer[n]) throw 'target "' + n + '" is exist!';
                if (i = r[n], l = i.master, targetContainer[n] = i, l) {
                    if (d = [], i.block = d, l = masterContainer[l], !l) continue;
                    for (f = l.block, p = 0, h = f.length; h > p; p++) g = f[p],
                    g.type === TYPE.CONTENTPLACEHOLDER ? (c = i.content[g.id], c && d.push.apply(d, c.block)) : d.push(g)
                }
            }
            r = null,
            a = null,
            s = null,
            o = null
        }
    } (),
    condExpr = function() {
        function andExpr(e) {
            var t, n = relationExpr(e);
            return (t = e.current()) && "&&" === t.text && (e.next(), n = {
                type: EXPR_T.and,
                expr1: n,
                expr2: andExpr(e)
            }),
            n
        }
        function orExpr(e) {
            var t, n = andExpr(e);
            return (t = e.current()) && "||" === t.text && (e.next(), n = {
                type: EXPR_T.or,
                expr1: n,
                expr2: orExpr(e)
            }),
            n
        }
        function primaryExpr(e) {
            var t = e.current();
            return "(" === t.text && (e.next(), t = orExpr(e)),
            e.next(),
            t
        }
        function unaryExpr(e) {
            return "!" === e.current().text ? (e.next(), {
                type: EXPR_T.unary,
                oper: "!",
                expr: primaryExpr(e)
            }) : primaryExpr(e)
        }
        function relationExpr(e) {
            var t, n = unaryExpr(e);
            return (t = e.current()) && /^[><=]+$/.test(t.text) && (e.next(), n = {
                type: EXPR_T.relation,
                expr1: n,
                expr2: unaryExpr(e),
                oper: t.text
            }),
            n
        }
        function execRelationExpr(e, t) {
            var n = execCondExpr(e.expr1, t),
            i = execCondExpr(e.expr2, t);
            switch (e.oper) {
            case "==":
                return n == i;
            case "===":
                return n === i;
            case ">":
                return n > i;
            case "<":
                return i > n;
            case ">=":
                return n >= i;
            case "<=":
                return i >= n;
            case "!=":
                return n != i;
            case "!==":
                return n !== i
            }
        }
        function execCondExpr(expr, scope) {
            switch (expr.type) {
            case EXPR_T.or:
                return execCondExpr(expr.expr1, scope) || execCondExpr(expr.expr2, scope);
            case EXPR_T.and:
                return execCondExpr(expr.expr1, scope) && execCondExpr(expr.expr2, scope);
            case EXPR_T.unary:
                return ! execCondExpr(expr.expr, scope);
            case EXPR_T.relation:
                return execRelationExpr(expr, scope);
            case EXPR_T.string:
            case EXPR_T.number:
                return eval(expr.text);
            case EXPR_T.variable:
                return getVariableValue(scope, expr.text, "raw")
            }
        }
        var EXPR_T = {
            or: 1,
            and: 2,
            relation: 3,
            unary: 4,
            string: 5,
            number: 6,
            variable: 7,
            punc: 8
        };
        return {
            parse: function(e) {
                e = util.trim(e);
                for (var t, n, i, r = e,
                a = []; e;) {
                    if (t = CONDEXPR_RULE.exec(e), !t) throw "conditional expression invalid: " + r;
                    if (e = e.slice(t[0].length), n = t[1], 0 === n.indexOf("$")) a.push({
                        type: EXPR_T.variable,
                        text: n.slice(2, n.length - 1)
                    });
                    else if (/^[-0-9]/.test(n)) a.push({
                        type: EXPR_T.number,
                        text: n
                    });
                    else switch (n) {
                    case "'":
                    case '"':
                        for (var o, s = [n], u = 0;;) {
                            if (o = e.charAt(u++), o === n) {
                                s.push(n),
                                e = e.slice(u);
                                break
                            }
                            s.push(o)
                        }
                        a.push({
                            type: EXPR_T.string,
                            text: s.join("")
                        });
                        break;
                    default:
                        a.push({
                            type:
                            EXPR_T.punc,
                            text: n
                        })
                    }
                }
                return i = orExpr(new NodeIterator(a))
            },
            exec: execCondExpr
        }
    } (),
    template = {
        addFilter: function(e, t) {
            filterContainer[e] = t
        },
        get: getTargetContent,
        parse: parse,
        merge: merge
    };
    return template
}),
define("common/util",
function(require) {
    var e = require("../lib/er/template"),
    t = require("../lib/er/Model"),
    n = require("../lib/underscore/underscore"),
    i = require("./data");
    return n.templateSettings = {
        interpolate: /\#\{(.+?)\}/g
    },
    {
        parseTpl: function(n, i) {
            var r = document.createElement("div");
            return e.merge(r, n, new t(i)),
            r.innerHTML
        },
        renderTpl: function(n, i, r) {
            e.merge(n, i, new t(r))
        },
        getRequestParams: function(e) {
            var t = {
                mode: 0,
                page: i.get("page"),
                cityid: i.get("cityid"),
                city: i.get("city"),
                sessionID: i.get("sessionID"),
                originQuery: i.get("originQuery"),
                sid: i.get("sid"),
                subqid: i.get("subqid"),
                srcid: i.get("srcid"),
                cardStyle: i.get("cardStyle")
            },
            n = i.get("tags");
            n && n.length > 0 && (t.tags = n.join(","));
            var r = i.get("orgid");
            r && (t.orgid = r);
            var a = i.get("fenlei");
            a && (t.fenlei = a);
            var o = i.get("uiSid");
            o && (t.uiSid = o);
            var s = i.get("classID");
            s && (t.classID = s),
            i.get("citychange") && (t.citychange = 1);
            var u = i.get("categoryID");
            u && (t.categoryID = u);
            var l = i.get("commonParams");
            for (var c in l) t[c] = l[c];
            e && $.extend(t, e);
            for (var c in t) null == t[c] && delete t[c];
            return t
        }
    }
}),
define("common/filter",
function(require, exports) {
    function e(e, t) {
        var r = i.get("tags");
        $.isArray(r) || (r = [], i.set("tags", r));
        var a = [],
        o = $(".filter-group:eq(" + e + ") a");
        if (o.each(function() {
            var e = this; - 1 !== e.className.indexOf("selected") && a.push(e.getAttribute("data-tagid"))
        }), a.length > 0) {
            var s = a[0];
            s >= 0 && (e = $.inArray(s, r), e >= 0 && r.splice(e, 1))
        }
        t >= 0 && r.push(t),
        n.uniq(r)
    }
    var t = require("../lib/er/Observable"),
    n = (require("../lib/er/Model"), require("../lib/er/URL"), require("../lib/er/template"), require("../lib/underscore/underscore")),
    i = (require("./util"), require("./data"));
    t.enable(exports);
    exports.init = function() {
        var t = $("#main");
        t.attr("data-click", '{"mod":"filter"}'),
        t.on("click", "a",
        function(t) {
            var n = $(t.target),
            r = n.attr("data-tagid");
            if (r) {
                var a = n.closest(".filter-group"),
                o = a.data("index");
                e(o, r),
                i.set("page", 1),
                exports.fire({
                    type: "change"
                })
            }
        }),
        t.on("click", ".more",
        function(e) {
            var t = $(e.target),
            n = t.closest(".filter-group");
            n.toggleClass("opened")
        })
    },
    exports.initMoreBtn = function() {
        $("#filter .more").each(function() {
            var e = $(this),
            t = e.closest(".filters"),
            n = t.closest(".filter-group");
            t.height() > n.height() && e.show(300)
        })
    },
    exports.renderTagsBg = function() {
        var e = i.get("tags");
        e && $.each(e,
        function(e, t) {
            var n = $('.filters a[data-tagid="' + t + '"]');
            n && $('.filters a[data-tagid="' + t + '"]').addClass("selected")
        });
        var t = $(".filters");
        $.each(t,
        function() {
            var e = $(this);
            e.closest(".filter-categroy").length || 0 === e.find(".selected").length && e.find("li:eq(0) a").addClass("selected")
        })
    }
}),
define("common/widget/Backtop",
function() {
    function e(e) {
        $.extend(this, n, e),
        this.init()
    }
    e.prototype = {
        init: function() {
            t || (t = $(window));
            var e = this;
            this.refresh(function() {
                e.element.show()
            },
            function() {
                e.element.hide()
            }),
            t.on("scroll",
            function() {
                e.refresh(function() {
                    e.element.fadeIn(500)
                },
                function() {
                    e.element.fadeOut(500)
                })
            }),
            this.element.on("click",
            function() {
                e.backToTop()
            })
        },
        refresh: function(e, n) {
            t.scrollTop() > this.minY ? e() : n()
        },
        backToTop: function() {
            $("html, body").animate({
                scrollTop: 0
            },
            {
                duration: this.duration,
                easing: this.easing
            })
        },
        dispose: function() {
            this.element.off("click"),
            t.off("scroll"),
            t = null
        }
    };
    var t, n = {
        minY: 200,
        duration: 500,
        easing: "swing"
    };
    return e
}),
define("common",
function(require) {
    "use strict";
    var e = require("./common/data"),
    t = require("./common/header"),
    n = require("./common/menu"),
    i = require("./common/pager"),
    r = require("./common/tip"),
    a = require("./common/filter"),
    o = (require("./common/redirect"), require("./common/widget/Backtop")),
    s = require("./common/inputSugg"),
    exports = $({}),
    u = '<div class="backtop" title="è¿åé¡¶é¨"></div>';
    exports.renderEduWidgets = function() {
        $("#advice")[0].onclick = bds.qa.ShortCut.initRightBar,
        $(".edu-widgets").append(u);
        new o({
            element: $(".backtop")
        })
    },
    exports.renderPlatform = function() {
        require(["site"],
        function(e) {
            e.render({
                header: {
                    nav: "platform-header"
                },
                footer: {
                    nav: "footer"
                }
            })
        })
    },
    exports.initFilter = function() {
        a.init(),
        a.on("change",
        function() {
            exports.trigger("filterChange")
        })
    },
    exports.initMoreBtn = function() {
        a.initMoreBtn()
    },
    exports.renderTagsBg = function() {
        a.renderTagsBg()
    },
    exports.renderTip = function() {
        r.initTips()
    },
    exports.renderMenu = function() {
        n.init()
    };
    var l;
    return exports.initHeader = function(e) {
        t.init(e),
        t.on("citychange",
        function() {
            exports.setData("classID", null),
            exports.trigger("cityChange")
        })
    },
    exports.initSuggestion = function(e) {
        s.initRecWords(e)
    },
    exports.renderPager = function(e) {
        l = e,
        i.init({
            main: e.main,
            page: e.page,
            totalPage: e.total
        }),
        "function" == typeof e.onpagechange && i.on("change", e.onpagechange)
    },
    exports.refreshPager = function(e) {
        try {
            i.refresh(e.page, e.total)
        } catch(t) {
            l.page = e.page,
            l.total = e.total,
            exports.renderPager(l)
        }
    },
    exports.getData = function(t) {
        return e.get(t)
    },
    exports.setData = function(t, n) {
        e.set(t, n)
    },
    exports.fireDataChange = function() {
        e.fireChange()
    },
    exports
}),
define("new_index",
function(require, exports) {
    "use strict";
    var e = require("common/log"),
    t = require("common/header"),
    n = require("common/menu"),
    i = require("common/redirect"),
    r = require("common"),
    a = require("common/util"),
    o = require("cobble/cookie"),
    s = $(".month-item"),
    u = $(".prev-month-btn"),
    l = $(".next-month-btn");
    t.submitForm = function() {
        i.toCourse({
            sessionID: null
        })
    };
    var c = {
        init: function(e) {
            var t = this;
            e.on("mouseenter", ".list-item",
            function(e) {
                var n = $(e.currentTarget);
                n.find(".hot-query-layer").show(),
                n.addClass(t.getItemHoverClass(n))
            }).on("mouseleave", ".list-item",
            function(e) {
                var n = $(e.currentTarget);
                n.removeClass(t.getItemHoverClass(n)),
                n.find(".hot-query-layer").hide()
            })
        },
        getItemHoverClass: function(e) {
            var t = e.data("type");
            return t + "-item-hover"
        }
    },
    d = {
        monthListLeft: null,
        examDescLeft: null,
        init: function() {
            var e = this;
            e.monthListLeft = parseInt($(".month-list").css("left")),
            e.examDescLeft = parseInt($(".exam-list ").css("left")),
            s.on("click",
            function(t) {
                var n = $(".selected-month"),
                i = n.data("month"),
                r = $(t.currentTarget),
                a = r.data("month");
                e.changeMonth(a),
                e.slideExamDesc(i, a)
            }),
            u.on("click",
            function() {
                if (!$(this).hasClass("prev-month-disable")) {
                    var t = $(".selected-month"),
                    n = t.data("month"),
                    i = n - 1;
                    e.slideMonth($(this), i),
                    e.changeMonth(i),
                    e.slideExamDesc(n, i)
                }
            }),
            l.on("click",
            function() {
                if (!$(this).hasClass("next-month-disable")) {
                    var t = $(".selected-month"),
                    n = t.data("month"),
                    i = n + 1;
                    e.slideMonth($(this), i),
                    e.changeMonth(i),
                    e.slideExamDesc(n, i)
                }
            })
        },
        dispose: function() {
            s.off("click"),
            u.off("click"),
            l.off("click")
        },
        judgeBtnDisable: function() {
            var e = $(".selected-month"),
            t = e.data("month");
            1 == t ? u.addClass("prev-month-disable") : 12 == t ? l.addClass("next-month-disable") : (u.removeClass("prev-month-disable"), l.removeClass("next-month-disable"))
        },
        changeMonth: function(e) {
            var t = $(".selected-month"),
            n = $(".month-item").eq(e - 1);
            t.removeClass("selected-month"),
            n.addClass("selected-month")
        },
        slideExamDesc: function(e, t) {
            var n = this,
            i = 200,
            r = $(".exam-item").outerWidth(),
            a = $(".exam-list"),
            o = n.examDescLeft,
            s = -r * (t - e);
            n.examDescLeft = o + s,
            a.animate({
                left: n.examDescLeft
            },
            {
                duration: i * Math.abs(t - e),
                easing: "swing"
            }),
            n.judgeBtnDisable()
        },
        slideMonth: function(e, t) {
            var n = this,
            i = $(".month-list"),
            r = n.monthListLeft,
            a = $(".month-item"),
            o = a.outerWidth() + parseInt(a.css("margin-right")),
            s = r - o,
            u = -Math.round(r / o) + 1,
            l = u + 4;
            e.hasClass("next-month-btn") ? t - u >= 5 && (n.monthListLeft = r - o, i.animate({
                left: s
            },
            {
                duration: 200
            })) : l - t >= 5 && (n.monthListLeft = r + o, i.animate({
                left: r + o
            },
            {
                duration: 200
            }))
        }
    },
    f = {
        count: 0,
        newsNum: $(".layer").length,
        newsHeight: $(".real").outerHeight(),
        init: function() {
            var e = this;
            e.slideUpNews(e.count++),
            setTimeout(function() {
                e.init()
            },
            2e3)
        },
        slideUpNews: function(e) {
            var t = this;
            if (e < t.newsNum) {
                var n = $(".layer").eq(e);
                n.addClass("cur"),
                n.animate({
                    top: -t.newsHeight
                },
                {
                    duration: 1e3,
                    easing: "swing",
                    complete: function() {
                        var e = $(".cur");
                        $.proxy(t.recoverNews(e), t)
                    }
                })
            } else t.count = 0
        },
        recoverNews: function(e) {
            e.css({
                top: 0
            }),
            e.removeClass("cur")
        }
    },
    p = {
        stepNum: 0,
        bannerNum: null,
        colorMap: {},
        init: function() {
            var e = this;
            e.changeProperty(e.stepNum++),
            setTimeout(function() {
                e.init()
            },
            3e3)
        },
        addHandler: function() {
            var e = this,
            t = $(".image-btn a"),
            n = !1;
            t.on("mouseenter",
            function(t) {
                n = !0,
                setTimeout(function() {
                    if (n) {
                        var i = $(t.target),
                        r = $(".image-btn .current");
                        r.removeClass("current"),
                        i.addClass("current"),
                        e.changeProperty(i.data("order")),
                        e.stepNum = i.data("order")
                    }
                },
                100)
            }),
            t.on("mouseleave",
            function() {
                n = !1
            })
        },
        changeProperty: function(e) {
            var t = this,
            n = $(".center-content .image-list");
            if (e < t.bannerNum + 1) {
                var i = e % t.bannerNum,
                r = $(".image-btn a").eq(i),
                a = $(".image-btn .current"),
                o = $("#index-floor-wrapper"),
                s = "step" + e;
                a.removeClass("current"),
                r.addClass("current"),
                n.animate({
                    left: t.colorMap[s].leftNum
                },
                {
                    duration: 400,
                    easing: "swing",
                    complete: function() {
                        e == t.bannerNum && (n.css({
                            left: "0px"
                        }), t.stepNum = 1)
                    }
                }),
                o.css({
                    "background-color": t.colorMap[s].bColor
                })
            }
        },
        renderBannerConfig: function(e) {
            var t = $.parseJSON(e);
            this.bannerNum = t.main_img_num;
            var n = t.main_img,
            i = n.length,
            r = 691;
            for (var a in n) this.colorMap["step" + a] = {
                leftNum: -r * a,
                bColor: n[a].color
            };
            this.colorMap["step" + i] = {
                leftNum: -r * i,
                bColor: n[0].color
            }
        }
    },
    h = {
        init: function() {
            var e = $(".dxt-floor .content-container");
            e.on("mouseenter", ".video-image-wrapper",
            function(e) {
                $(e.currentTarget).addClass("image-hover")
            }).on("mouseleave", ".video-image-wrapper",
            function(e) {
                $(e.currentTarget).removeClass("image-hover")
            })
        }
    },
    g = {
        init: function() {
            var e = $(".subject-wrapper");
            e.on("click", ".close-button",
            function() {
                e.animate({
                    height: 0
                },
                {
                    duration: 400,
                    easing: "swing",
                    complete: function() {
                        o.set("fe_banner_hidden", "1", {
                            expires: 3
                        })
                    }
                })
            })
        },
        suggestRedirect: function(e) {
            i.toCourse({
                originQuery: e,
                key: e,
                sessionID: null
            })
        }
    },
    m = {
        init: function() {
            var e = this.getParams();
            exports.requestHotCourseList(e)
        },
        render: function(e) {
            $(".hot-course-container").html(e)
        },
        getParams: function() {
            var e = location.search,
            t = e.substr(1).split("&"),
            n = {};
            for (var i in t) {
                var r = t[i],
                a = r.split("=")[0]; ("zt" == a || "wd" == a) && (n[a] = r.split("=")[1])
            }
            return n
        }
    };
    exports.init = function(i) {
        m.init(),
        d.judgeBtnDisable(),
        d.init(),
        c.init($(".category-main")),
        f.init(),
        p.renderBannerConfig(i.bannerList),
        p.init(),
        p.addHandler(),
        r.renderPlatform(),
        r.renderTip(),
        r.renderEduWidgets(),
        t.init(),
        r.initSuggestion(g.suggestRedirect),
        n.init(),
        h.init(),
        g.init(),
        e.initHunter("38644"),
        e.initLog()
    },
    exports.requestHotCourseList = function(e) {
        var t = a.getRequestParams(e);
        $.get("/mp/hotcourse", t,
        function(e) {
            var t = 0 === e.status ? e.data: {},
            n = t.tpl.hot_course || "";
            m.render(n)
        },
        "json")
    }
});
