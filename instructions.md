
Command to run spark container
https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-etl-libraries.html
```docker run -it -v ~/.aws:/home/glue_user/.aws -v WORKSPACE_LOCATION:/home/glue_user/workspace/ -e AWS_PROFILE=terraform -e DISABLE_SSL=true --rm -p 4040:4040 -p 18080:18080 --name glue_pyspark amazon/aws-glue-libs:glue_libs_4.0.0_image_01 pyspark```