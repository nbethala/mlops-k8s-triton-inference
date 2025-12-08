# services/triton/Dockerfile
FROM nvcr.io/nvidia/tritonserver:24.01-py3-min
WORKDIR /opt/tritonserver

# Do NOT copy models into the image
# Optional: add entrypoint/args if you want
ENTRYPOINT ["tritonserver"]
CMD ["--model-repository=/models","--model-control-mode=poll","--repository-poll-secs=5"]
