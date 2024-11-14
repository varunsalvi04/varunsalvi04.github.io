const MongoClient = require('mongodb').MongoClient;
const uri = "mongodb+srv://varunmil:cD4gzn7kDDEbpYik@cluster0.0jgp2.mongodb.net/";

module.exports = {
    addFavoriteAddress: async function(address) {
        // const uri = process.env.DB_URI;
        let mongoClient;
        try {
            console.log("Adding city");
            mongoClient = await connectToCluster(uri);
            const db = mongoClient.db('favorite');
            const collection = db.collection('favorite');
            await collection.insertOne(address);
        } catch(e){
            console.log(e)
        }finally {
            await mongoClient.close();
        }
    },

   deleteFavoriteAddress: async function(city) {
        // const uri = process.env.DB_URI;
        let mongoClient;
        try {
            console.log("Deleteing city");
            mongoClient = await connectToCluster(uri);
            const db = mongoClient.db('favorite');
            const collection = db.collection('favorite');
            await collection.deleteMany({ city });
            return await collection.find({},{projection:{ _id: 0 }}).toArray();
        } finally {
                await mongoClient.close();
        }
    },
    listFavoriteAddresses: async function() {
        // const uri = process.env.DB_URI;
        let mongoClient;
        try {
            console.log("Deleteing city");
            mongoClient = await connectToCluster(uri);
            const db = mongoClient.db('favorite');
            const collection = db.collection('favorite');
            return await collection.find({},{projection:{ _id: 0 }}).toArray();
            // console.log(list)
            // return list
        } finally {
                await mongoClient.close();
        }
    }

};

async function connectToCluster(uri) {
    let mongoClient;

    try {
        mongoClient = new MongoClient(uri);
        console.log('Connecting to MongoDB Atlas cluster...');
        await mongoClient.connect();
        console.log('Successfully connected to MongoDB Atlas!');

        return mongoClient;
    } catch (error) {
        console.error('Connection to MongoDB Atlas failed!', error);
        process.exit();
    }
}

async function init(){
    // const uri = "mongodb+srv://varunmil:YWb2K38fAn0aY5b5@cluster0.wum1t.mongodb.net/";
        let mongoClient;
        try {
            console.log("Setting Indices")
            mongoClient = await connectToCluster(uri);
            const db = mongoClient.db('favorite');
            const collection = db.collection('favorite');
            await collection.createIndex( { "city": 1 }, { unique: true } );
        } finally {
            await mongoClient.close();
        }
}

init()


