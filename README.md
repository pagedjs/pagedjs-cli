# PagedJS PDF Renderer

Render Html to PDFs using [Pagedjs](https://gitlab.pagedmedia.org/polyfills/pagedjs) and [Puppeteer](https://github.com/GoogleChrome/puppeteer).

## Installation

```
npm install -g pagedjs-cli
```

## Generating a PDF

```
pagedjs-cli ./path/to/index.html -o result.pdf
```

## Options

```
-i, --inputs [inputs]                Inputs
-o, --output [output]                Output
-d, --debug                          Debug
-l, --landscape                      Landscape printing (default: false)
-s, --page-size [size]               Print to Page Size [size]
-w, --width [size]                   Print to Page Width [width] in MM
-h --height [size]                   Print to Page Height [weight] in MM
--forceTransparentBackground         Print with transparent background
-t, --timeout [ms]                   Set a max timeout of [ms]
-x, --html                           output html file
-b, --blockLocal                     Disallow access to filesystem for local files
-r, --blockRemote                    Disallow requests to remote servers
--allowedPath [allowedPaths]         Only allow access to given filesystem paths,
                                      repeatable. (default: [])
--allowedDomain [allowedDomains]     Only allow access to given remote domains, repeatable
                                      (default: [])
--outline-tags [tags]                Specifies that an outline should be generated for the
                                      resulting PDF document. [tags] specifies which HTML
                                      tags should be considered for that outline. "h1,h2"
                                      will trigger an outline with "h1" tags as root
                                      elements and "h2" elements as their childs.
--additional-script <script>         Additional script tags which are added to the HTML
                                      document before rendering. This is useful for adding
                                      custom pagedjs handlers. The option can be repeated.
                                      (default: [])
--browserEndpoint <browserEndpoint>  Use a remote Chrome server with browserWSEndpoint
--browserArgs <browserArgs>          Launch Chrome with comma separated args
--media [media]                      Emulate "print" or "screen" media, defaults to print.
--style <style>                      Path to CSS stylesheets to be added before rendering
                                      (default: [])
--warn                               Enable warning logs
--extra-header <header:value>        Header to be added to the page request. (default: [])
--help                               display help for command
--disable-script-injection           Disable in injection of the polyphill script.
```

## Development
Link and build the JS
```
npm install
npm link
npm install -g gulp

gulp watch
```

To display the output in the browser window before printing,
instead of outputting the file add the `--debug` flag.

```
pagedjs-cli ./path/to/index.html --debug
```

## Testing

Install Mocha with `npm install -g mocha`

Run the tests from the library root with the `mocha` command
```
mocha
```

## Docker

Build the Docker image

```bash
docker build -t pagedmedia/pagedjs-cli .
```

Run the Docker image

```bash
docker run -it --init --security-opt 'seccomp=seccomp.json' pagedmedia/pagedjs-cli bash
```
