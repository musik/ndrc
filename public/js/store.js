var store=function(){function e(){return t?t:(t=o.body.appendChild(o.createElement("div")),t.style.display="none",t.addBehavior("#default#userData"),t.load(i),t)}var t,n={},r=window,o=r.document,i="localStorage",a="globalStorage";return n.set=function(){},n.get=function(){},n.remove=function(){},n.clear=function(){},i in r&&r[i]?(t=r[i],n.set=function(e,n){t.setItem(e,n)},n.get=function(e){return t.getItem(e)},n.remove=function(e){t.removeItem(e)},n.clear=function(){t.clear()}):a in r&&r[a]?(t=r[a][r.location.hostname],n.set=function(e,n){t[e]=n},n.get=function(e){return t[e]&&t[e].value},n.remove=function(e){delete t[e]},n.clear=function(){for(var e in t)delete t[e]}):o.documentElement.addBehavior&&(n.set=function(t,n){var r=e();r.setAttribute(t,n),r.save(i)},n.get=function(t){var n=e();return n.getAttribute(t)},n.remove=function(t){var n=e();n.removeAttribute(t),n.save(i)},n.clear=function(){var t=e(),n=t.XMLDocument.documentElement.attributes;t.load(i);for(var r,o=0;r=n[o];o++)t.removeAttribute(r.name);t.save(i)}),n}();