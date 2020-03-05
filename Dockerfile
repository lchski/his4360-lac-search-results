FROM trestletech/plumber
LABEL maintainer="lchski"

RUN install2.r --error \
    --deps TRUE \
    tidyverse \
    dplyr \
    jsonlite

COPY [".", "./"]

ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(commandArgs()[4]); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT')))"]
CMD ["api.R"]
