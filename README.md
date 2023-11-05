# solarmesh.cn

The [solarmesh.cn](https://solarmesh.cn) website, built using [Hugo](https://gohugo.io) and hosted on [Netlify](https://www.netlify.com/).

## Build

To build and serve the site, you'll need the latest [LTS release][] of **Node**.
Like Netlify, we use **[nvm][]**, the Node Version Manager, to install and
manage Node versions:

```console
$ nvm install --lts
```

### Setup

 1. Clone this repo.
 2. From a terminal window, change to the cloned repo directory.
 3. Get NPM packages and git submodules, including the the [Docsy](https://www.docsy.dev/) theme:
    ```console
    $ npm install
    ```

### Build or serve the site

To locally serve the site at [localhost:1313 ](http://localhost:1313), run the following command:

```console
$ npm run serve
```

To build and check links, run these commands:

```console
$ npm run build
$ npm run check-links
```

You can also locally serve using [Docker](https://docker.com):

```console
$ make docker-serve
```

### Build Image

```shell
wget https://github.com/gohugoio/hugo/releases/download/v0.89.4/hugo_extended_0.89.4_Linux-64bit.tar.gz
tar -zxvf hugo_extended_0.89.4_Linux-64bit.tar.gz

git clone https://github.com/mark8s/solarmesh-website.git
cp hugo ./solarmesh-website
cd solarmesh-website

docker build -t ${Image} .
```

### Docker start

```shell
docker run -d -p 8888:8888 --restart always ${Image}
```

