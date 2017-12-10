lizbon =
	$(document).on 'ready page:load', ->
			$ ->
				#1min reload
				timer = setInterval (->
					location.reload()
					return
				), 1000 * 60

				$("#reload").click ->
					clearInterval(timer)