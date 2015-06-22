# kiwi conversations - key context

warning - this project is many commits away from being a useful thing.

------------------------------------------------------------------------

- written with coffeescript (www.coffeescript.org).
- use the command 'coffee -o kiwi/package -cw kiwi/coffeescripts'
from the root directory

- To just toy around with extension and not worry about minification.
- Go to popup.html and uncomment the script popup.js and background.js lines
(and comment out the popup.min.js and background.min.js)
^^ then do the same in the manifest.json.
-Then you can load unpacked extension.

- using uglify for minification (https://www.npmjs.com/package/uglify-js)
- use the command 
uglifyjs popup.js --compress -o popup.min.js
uglifyjs background.js --compress -o background.min.js
and then manually delete extra JS files before zipping package

