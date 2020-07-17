$(document).ready(function() {
        //new WOW().init();
});

$.fn.exists = function (){
  return this.length > 0;
};

(function () {
        //
        // thanks for https://stackoverflow.com/questions/26700853/smooth-scrolling-on-mouse-wheel
        //
        function SmoothScroll(element, opts) {
          this.$el = $(element);
          this.opts = opts;
          this.init();
        }

        SmoothScroll.setting = {
          step: 1000,
          speed: 450 };


        SmoothScroll.prototype = {
          constructor: SmoothScroll,

          init() {
            $.extend(this, SmoothScroll.setting, this.opts);
            this._wheelHandler = $.proxy(this._wheelHandler, this);
            this.$el.on("wheel", this._wheelHandler);
          },

          _wheelHandler($e) {

            let direction = $e.originalEvent.deltaY > 0 ? "+=" : "-=";

            this.$el.stop().animate({
              scrollTop: direction + this.step },
            this.speed);
            $e.preventDefault();
          },

          destroy() {
            this.$el.off('wheel', this._wheelHandler);
          } };


        $.fn.smoothScroll = function (opts) {
          this.each((index, el) => {
            let smoothScroll = new SmoothScroll(el, opts);
          });
        };
      })();


      //$('body').smoothScroll();

      var $preloader 	= $('.preloader'),
            $spinner 	= $('.spinner');
            $body 	= $('body');


		// if ($preloader.exists()) {
    //         $body.addClass("page-loaded");
    //         $spinner.addClass("load-done");
    //         if(!$spinner.hasClass('spinner-alt')){
    //             $spinner.fadeOut(300);
    //         }
    //         $preloader.delay(9000).fadeOut(300);
    //     }

        window.onload = function () {
          document.body.classList.add('loaded_hiding');
          window.setTimeout(function () {
            $body.addClass("page-loaded");
            $spinner.addClass("load-done");
            if(!$spinner.hasClass('spinner-alt')){
                $spinner.fadeOut(300);
            }
            $preloader.fadeOut(300);
          }, 500);
          //
        }
