$(document).ready(function() {
        new WOW().init();   
});

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
      
      
      $('body').smoothScroll();

