import express from 'express'

const app = express();

app.get('/', (req, res) => {
    console.log('hello 489')
   res.json('hello world v2!') 
});

app.listen(8082, () => {
    console.log('App started successfully!')
})