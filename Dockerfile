FROM rocker/tidyverse
LABEL maintainer="lchski"

RUN install2.r plumber

COPY [".", "./"]

ENTRYPOINT ["R", "-e", "pr <- plumber::plumb('api.R'); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT')))"]
