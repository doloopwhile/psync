jQuery ($) =>
  $.get "/files/index.json", (data) =>
    $("body").css({"background-image": "url(#{data.background_url})"})

    $m = $("body")
    for url, index in data.page_urls
      img = new Image()
      img.src = url
      width = img.width
      height = img.height

      $img = $("<img>")

      $img.
        attr({src: url}).
        data({"index", index}).
        css({
          "margin-left": -img.width / 2,
          "margin-top": -img.height / 2,
          "left": "#{50 + 100 * index}%",
        }).
        appendTo($m)

  polling = (new EventSource("/api/polling"))
  polling.onmessage = (e) =>
    i = JSON.parse(e.data)
    $("img").each ->
      $img = $(this)
      index = $img.data("index")
      $img.animate({
        left: "#{50 + 100 * (index - i)}%"
      })
    $(".page").text(i)

  $(document).mousemove (e) =>
    $(".mouse").text("(#{e.pageX}, #{e.pageY})")
