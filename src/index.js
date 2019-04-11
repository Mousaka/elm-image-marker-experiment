import { Elm } from './Main.elm'

var app = Elm.Main.init({
  node: document.querySelector('main')
})

app.ports.ourPort.subscribe((message) => {
    svgToUrl((url) => app.ports.newImage.send(url));
});

function svgToUrl(callback) {
  var svg = document.querySelector('svg');
  var canvas = document.createElement('canvas');
  var ctx = canvas.getContext('2d');
  var data = (new XMLSerializer()).serializeToString(svg);
  var DOMURL = window.URL || window.webkitURL || window;

  var img = new Image();
  var svgBlob = new Blob([data], {type: 'image/svg+xml;charset=utf-8'});
  var url = DOMURL.createObjectURL(svgBlob);

  img.onload = function () {
    ctx.drawImage(img, 0, 0);
    DOMURL.revokeObjectURL(url);

    var imgURI = canvas
        .toDataURL('image/png')
        .replace('image/png', 'image/octet-stream');

    callback(imgURI);
  };

  img.src = url;
}