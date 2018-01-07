lizbon =
	$(document).on 'ready page:load', ->
			$ ->
				#1min reload
				timer = setInterval (->
					location.reload()
					return
				), 1000 * 60

				reload = $("#reload").attr("data-reload")
				if reload == true
					clearInterval(timer)