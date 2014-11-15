(function() {
  jQuery((function(_this) {
    return function($) {
      var polling;
      $.get("/files/index.json", function(data) {
        var img, url, _i, _len, _ref;
        _ref = data.page_urls;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          url = _ref[_i];
          img = $("<img class='page'>").attr({
            src: url
          });
          if ($(".selected-page").length === 0) {
            img.addClass("selected-page");
          }
          img.appendTo($("#pages"));
        }
        return $("#display").attr({
          src: data.page_urls[0]
        });
      });
      $(document).on("click", ".page", function() {
        var url;
        $(".page").removeClass("selected-page");
        $(this).addClass("selected-page");
        url = $(this).attr("src");
        return $("#display").attr({
          src: url
        });
      });
      polling = new EventSource("/polling");
      return polling.onmessage = function(e) {
        var i, p, url;
        $("#polling").text(e.data);
        i = JSON.parse(e.data);
        p = $(".page").get(i);
        if (p == null) {
          return;
        }
        url = $(p).attr("src");
        return $("#display").attr({
          src: url
        });
      };
    };
  })(this));

}).call(this);
