# Deploying an application with Docker

You're already starting to get quite familiar with Docker, which is extremely handy for deploying applications. You've used containers (jupyter/pyspark-noteook, postgres, etc.), but you can also make your own containers! If you follow these instructions, you will find you have everything you need to run your application on a virtual machine like the one we've used on AWS in the brushups.

We will create a toy python application that accesses a mongo database and prints out some results. 

First, we will run our mongo database on our machine:

```shell
docker run -d --name foomongo -p 27017:27017 mongo
```

This should look familiar from running postgres, but now the port is different (this will be different for each database! You will have to read the documentation of the Docker image for the database. For example: https://hub.docker.com/_/mongo).

Now try inserting some data into your mongo database:

```shell
docker exec -i mongo mongo --eval "db.foo_collection.insert({'greeting': 'hello world'})" foo_db
```

Don't worry about that syntax for now, it's just an `INSERT` statement in Mongo's language, inserting a single item into a collection called `foo_collection` (collections are like tables) in the `foo_db` database. If your database is running, that should return something like `WriteResult({ "nInserted" : 1 })`.

Now that we have the database running, we need to create a container with our application! First, create a folder for our application. Create the following files:

```shell
├── Dockerfile
├── foo.py
└── utils
    ├── mongo.py
```

You can do that with the following commands:

```shell
touch Dockerfile
touch foo.py
mkdir utils
touch utils/mongo.py
```

Now let's edit the `utils/mongo.py` file to contain the following:

```python
from pymongo import MongoClient

def get_results():
    client = MongoClient('mongodb://localhost:27017')
    coll = client.foo_db['foo_collection']
    return list(coll.find())
```

Note the URL: `mongodb://localhost:27017` --> the `mongodb://` is the protocol (it's not HTTP!) and the `27017` is the port, and the part in the middle, `localhost`, tells us that it is running locally. Actually, this is the default address, so we could have just called `MongoClient()` without any arguments, but I wanted to be explicit so you see what to change if needed!

Now write the following in `foo.py`:

```python
from utils.mongo import get_results

res = get_results()
print(res)
```

As you can see, this imports our own function from our own module in our own folder. Then, it prints out the results of the function. Now write the folliwing in the `Dockerfile`:


```dockerfile
FROM python:3.7

RUN pip install tweepy pymongo

ADD . .

CMD [ "python", "./foo.py" ]
```

Finally, to create the image, we need to "build" it. We do this as follows (in the root of the folder):

```shell
docker build -t myname/fooapp .
```

This will build an image with the name `myname/fooapp` where `myname` is your "username" (more on that later, just pick anything for now) and `fooapp` is the name of the application itself. Now we can run the appliction:

```shell
docker run --name myfoo -d --net host myname/fooapp
```
And it should work!

Note the new flag: `--net` and the value `host`. Docker has an idea of "networks". You can read more about it in the Docker documentation. This allows us to access our mongo on `localhost` because we've merged the containers network with the network of the host computer.

If you are interested to know, the more "correct" way to do this would be to create our own custom network, run both the database and our app on that network, and use the docker container name in place of "localhost". However, this simple way of using the "host" network, which is always available, will have no downsides for such a simple application.

One last step: this image you just "built" is only available locally. But maybe you want to run it on your server! You can push it to a public repository. Just like we used Github to host code, we can use DockerHub to host images! Create a free account at: https://hub.docker.com. Now, when you use your new DockerHub username in the place of `myname` in the above examples, you will be able to run the following:

```shell
docker push myname/fooapp
```

And push your image to your repository. Now your image is available from anywhere, just like all the other Docker images we have been using! Now you can run the same "run" command on the server (or on any computer with Docker, anywhere) and it will just work!
