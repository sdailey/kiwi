# kiwi conversations (archived)

To see a demo video and what the project's homepage looked like,
visit https://www.metafruit.com/kiwi/ (the project has since been retired).

# original readme:

the firefox add-on repo can be found here: https://github.com/sdailey/kiwi-firefox


note: simply spinning up the extension on your machine won't quite work, as
you need to provide your own reddit app oauth client id.


homepage: http://www.metafruit.com/kiwi

------------------------------------------------------------------------

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

