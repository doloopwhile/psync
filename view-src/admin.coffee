jQuery ($) =>
  $.get "/files/index.json", (data) =>
    $m = $("body")
    for url, index in data.page_urls
      $d = $("<div>")
        .text(index)
        .appendTo($m)
      $("<img>")
        .attr({src: url})
        .data({"index": index})
        .appendTo($d)
        .click ->
          index = $(this).data("index")
          $.post "/api/move/#{index}"

  polling = (new EventSource("/api/polling"))
  polling.onmessage = (e) =>
    i = JSON.parse(e.data)
    $(".selected").removeClass("selected")
    $($("img").get(i)).addClass("selected")
