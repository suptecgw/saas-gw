<!DOCTYPE HTML>
<html lang="en">
<head>
	<title>Scott Andrew's HTML 5 Audio Player</title>
	
	
<style type="text/css">
		#jukebox {
			background-color:rgb(127, 178, 204);
			-moz-border-radius:10px;
			-webkit-border-radius:10px;
			color:#fff;
			padding:10px;
			font-family:helvetica, arial, verdana;
			font-weight:bold;
			width:300px;
		}
		#jukebox .loader {
			border:1px solid #fff;
			height:3px;
			margin:10px 0px
		}
		#jukebox .load-progress {
			width:0px;
			background-color:#fff;
			height:3px;
		}
		#jukebox .play-progress {
			width:0px;
			background-color:#cccccc;
			height:3px;
		}
		
		#jukebox .controls {
			text-align:center;
		}
		
		#jukebox .controls a {
			display:inline-block;
			width:33px;
			height:33px;
			margin:0px 14px;
			overflow:hidden;
			background-image:url('audio-controls.png');
			background-repeat:no-repeat;
		}
		
		#jukebox .controls a:hover {
			background-color:#ff9900;
		}
		
		#jukebox .controls a span {
			display:none;
		}
		
		#jukebox .controls a.prev {
			background-position:top -60px;
		}
		#jukebox .controls a.next {
			background-position:top -90px;
		}
		#jukebox .controls a.play {
                        background: url("img/icon-play.png") no-repeat;
			background-position: center;
		}
		#jukebox .controls a.pause {
                        background: url("img/icon-pause.png") no-repeat;
			background-position: center;
		}
		
	</style>
	
</head>

<body>

<div id="jukebox">
	<div class="info">${param.title}</div>
	<div class="loader">
		<div class="load-progress">
			<div class="play-progress">
			</div>
		</div>
	</div>
	<div class="controls">
		<a class="play" href="#"><span>Play</span></a>
		<a class="pause" href="#"><span>Pause</span></a>
	</div>
	<audio class="aud" src="${param.url}">
		<p>Oops, looks like your browser doesn't support HTML 5 audio.</p>
	</audio>
</div>

<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.0/jquery.min.js"></script>
<script type="text/javascript">

	// the playlist is just a JSON-style object.
//	var playlist = [
//		{
//			url : "${param.url}",
//			title : "Holding Back"
//		},
//		{
//			url : "http://www.scottandrew.com/mp3/wb/where_ive_been/Scott_Andrew_and_the_Walkingbirds-Gravel_Road_Requiem.mp3",
//			title : "Gravel Road Requiem"
//		},
//		{
//			url : "http://www.scottandrew.com/mp3/syfy/01%20-%20Scott%20Andrew%20-%20More%20Good%20Days.mp3",
//			title : "More Good Days"
//		}
//	];

	$(document).ready(function() {
	
	    var aud = $('#jukebox .aud').get(0);
	    aud.pos = -1;
	
		$('#jukebox .play').bind('click', function(evt) {
			evt.preventDefault();
                            aud.play();
		});
		
		$('#jukebox .pause').bind('click', function(evt) {
			evt.preventDefault();
			aud.pause();
		});
		
//		$('#jukebox .next').bind('click', function(evt) {
//			evt.preventDefault();
//			aud.pause();
//			aud.pos++;
//			if (aud.pos == playlist.length) aud.pos = 0;
//			aud.setAttribute('src', playlist[aud.pos].url);
//                        $('#jukebox .info').html(playlist[aud.pos].title);
//			aud.load();
//		});
//		
//		$('#jukebox .prev').bind('click', function(evt) {
//			evt.preventDefault();
//			aud.pause();
//			aud.pos--;
//			if (aud.pos < 0) aud.pos = playlist.length - 1;
//			aud.setAttribute('src', playlist[aud.pos].url);
//                        $('#jukebox .info').html(playlist[aud.pos].title);
//			aud.load();
//		});
		
		// JQuery doesn't seem to like binding to these HTML 5
		// media events, but addEventListener does just fine
		
		aud.addEventListener('progress', function(evt) {
			var width = parseInt($('#jukebox').css('width'));
			var percentLoaded = Math.round(evt.loaded / evt.total * 100);
			var barWidth = Math.ceil(percentLoaded * (width / 100));
			$('#jukebox .load-progress').css( 'width', barWidth );
			
		});
		
		aud.addEventListener('timeupdate', function(evt) {
		    var width = parseInt($('#jukebox').css('width'));
			var percentPlayed = Math.round(aud.currentTime / aud.duration * 100);
			var barWidth = Math.ceil(percentPlayed * (width / 100));
			$('#jukebox .play-progress').css( 'width', barWidth);
		});
		
		aud.addEventListener('canplay', function(evt) {
			$('#jukebox .play').trigger('click');
		});
		
		aud.addEventListener('ended', function(evt) {
			$('#jukebox .next').trigger('click');
		});
		
	
//		$('#jukebox .info').html(playlist[0].title);
                
	
	});
</script>



</body>
</html>
