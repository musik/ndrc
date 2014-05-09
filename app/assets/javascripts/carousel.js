var Mcarousel = function(t){
  var settings = {
    stepNum: t,
    bannerNum: 2,
    to: 3000
  }
    this.init = function() {
      addHandler()
      setTimeout(function() {
        (new Mcarousel(settings.stepNum)).run();
      },
      settings.to)
    }
    this.run = function() {
        changeProperty(settings.stepNum++);
        if (settings.stepNum >= settings.bannerNum) 
          settings.stepNum = 0;
        setTimeout(function() {
          (new Mcarousel(settings.stepNum)).run();
        },
        settings.to)
    }
    addHandler = function() {
        t = $(".image-btn a")
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
                    changeProperty(i.data("order")),
                    settings.stepNum = i.data("order")
                }
            },
            100)
        }),
        t.on("mouseleave",
        function() {
            n = !1
        })
    }
    changeProperty = function(e) {
        n = $(".center-content .image-list");
        if (e < settings.bannerNum) {
            r = $(".image-btn a").eq(e)
            a = $(".image-btn .current")
            o = $("#index-floor-wrapper")
            s = "step" + e;
            a.removeClass("current")
            r.addClass("current")
            n.animate({
                left: -691 * e
            },
            {
                duration: 600,
                easing: "swing",
                complete: function() {
                    //e == (settings.bannerNum - 1) && (n.css({
                        //left: "0px"
                    //}), settings.stepNum = 0)
                }
            })
            o.css({
                "background-color": $('.center-content .image-list img').eq(e).data("color")
            })
        }
    }
    //renderBannerConfig = function(e) {
        //var t = $.parseJSON(e);
        //this.bannerNum = t.main_img_num;
        //var n = t.main_img,
        //i = n.length,
        //r = 691;
        //for (var a in n) this.colorMap["step" + a] = {
            //leftNum: -r * a,
            //bColor: n[a].color
        //};
        //this.colorMap["step" + i] = {
            //leftNum: -r * i,
            //bColor: n[0].color
        //}
    //}
}
$(document).ready(function(){
  (new Mcarousel(0)).init();
})
