jQuery ($) =>
  $.get "/files/index.json", (data) =>
    for url in data.page_urls
      img = $("<img class='page'>").attr(src: url)
      if $(".selected-page").length == 0
        img.addClass("selected-page")
      img.appendTo($("#pages"))
    $("#display").attr(src: data.page_urls[0])

  $(document).on "click", ".page", ->
    $(".page").removeClass("selected-page")
    $(this).addClass("selected-page")
    url = $(this).attr("src")
    $("#display").attr(src: url)
