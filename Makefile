NAME := blog
DOCKER_FLAGS+=--rm -i	--disable-content-trust=true -v $(CURDIR):/src/$(NAME) --workdir /src/$(NAME)

all: static/css/site.min.css

.PHONY: image-dev
image-dev:
	@docker build --rm --force-rm -f Dockerfile -t $(NAME):dev .

.PHONY: static/css/site.min.css
static/css/site.min.css: image-dev
	@docker run $(DOCKER_FLAGS) $(NAME):dev \
		sh -c 'cat static/css/fontawesome.css static/css/normalize.css static/css/code.css static/css/main.css | cleancss -o $@'

.PHONY: watch-css
watch-css: image-dev
	@docker run $(DOCKER_FLAGS) $(NAME):dev \
		sh -c "nodemon -x 'cat static/css/fontawesome.css static/css/normalize.css static/css/code.css static/css/main.css | cleancss -o $@' -w static/css -e css"
