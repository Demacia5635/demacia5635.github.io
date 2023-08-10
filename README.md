# Demacia's Website

![The Demacia logo](./Resources/img/logo.png)

[Demacia#5635](https://www.thebluealliance.com/team/5635)'s website

## Contributing

The website is built with the [Publish](https://github.com/JohnSundell/Publish) static site generator. Since the generator is still new and the ecosystem is quite limited some other tools were used for better performance.

### Prerequisites

For different optimization steps the project uses some additional tools that need to be downloaded beforehand.

1. `libwebp`

   A tool that's used for making WebP images as part of the automatic image optimization step.

   You can download it from the [libwebp download page](https://developers.google.com/speed/webp/docs/precompiled)

2. `node`

   All of the following tools require NodeJS and its package manager NPM.

   You can download it from the [NodeJS download page](https://nodejs.org/en-us/)

3. `imagemin-cli`

   A command line tool that can be used for minifying images. It is used as part of the automatic image optimization step.

   It can be installed with NPM using the command: `npm i -g imagemin-cli`.

4. `critical`

   A tool that finds and inlines all of the critical CSS found in each HTML page. It is used as part of the automatic CSS optimization step.

   It can be installed with NPM using the command: `npm i -g critical`.

5. `purifycss`

   A tool that finds all of the unused CSS rules in each stylesheet and removes them.

   It can be installed with NPM using the command: `npm i -g purifycss`.

6. `terser`

   A tool that minifies and mangles each and every JS file in the project (supports ES6+).

   It can be installed with NPM using the command: `npm i -g terser`.

7. `publish-cli`

   The Publish package also provides a CLI, the instructions for installing it are [written in the official README](https://github.com/JohnSundell/Publish#installation).

### Building

After installing all of the prerequisites the site can be generated. It can be generated and run using the command `publish run`.

Note that the generation process can take a while because of all of the different optimization steps.

### Deploying

Deploying the site can be done using the command `publish deploy`.

It doesn't seem like it regenerates the site before deployment so I'd suggest running `publish run` and only then `publish deploy`.

## License

GNU Affero General Public License v3.0 or later

See [LICENSE](./LICENSE) to see the full text.
