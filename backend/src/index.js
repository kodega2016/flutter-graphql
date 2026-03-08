import 'dotenv/config';
import http from 'http';
import express from 'express';
import cors from 'cors';
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@as-integrations/express5';
import { ApolloServerPluginDrainHttpServer } from '@apollo/server/plugin/drainHttpServer';
import { makeExecutableSchema } from '@graphql-tools/schema';
import { WebSocketServer } from 'ws';
import { useServer } from 'graphql-ws/use/ws';

import { typeDefs, resolvers } from './graphql/schema.js';
import { verifyToken } from './auth/jwt.js';


const PORT = process.env.PORT || 4000;

const app = express();
const httpServer = http.createServer(app);

const schema = makeExecutableSchema({
    typeDefs,
    resolvers,
});

const wsServer = new WebSocketServer({
    server: httpServer,
    path: '/graphql',
});

const serverCleanup = useServer(
    {
        schema,
        context: async (ctx) => {
            const authHeader =
                ctx.connectionParams?.Authorization ||
                ctx.connectionParams?.authorization ||
                null;

            if (!authHeader) {
                return { user: null };
            }

            const token = String(authHeader).replace('Bearer ', '');
            const payload = verifyToken(token);

            if (!payload) {
                return { user: null };
            }

            return {
                user: {
                    id: payload.userId,
                    email: payload.email,
                },
            };
        },
        onConnect: async (ctx) => {
            const authHeader =
                ctx.connectionParams?.Authorization ||
                ctx.connectionParams?.authorization;

            if (!authHeader) {
                throw new Error('Missing auth token');
            }
        },
    },
    wsServer
);

const apolloServer = new ApolloServer({
    schema,
    plugins: [
        ApolloServerPluginDrainHttpServer({ httpServer }),
        {
            async serverWillStart() {
                return {
                    async drainServer() {
                        await serverCleanup.dispose();
                    },
                };
            },
        },
    ],
});

await apolloServer.start();

app.use(
    '/graphql',
    cors(),
    express.json(),
    expressMiddleware(apolloServer, {
        context: async ({ req }) => {
            const authHeader = req.headers.authorization || '';
            const token = authHeader.replace('Bearer ', '');
            const payload = token ? verifyToken(token) : null;

            return {
                user: payload
                    ? {
                        id: payload.userId,
                        email: payload.email,
                    }
                    : null,
            };
        },
    })
);

await new Promise((resolve) => {
    httpServer.listen(PORT, resolve);
});

console.log(`🚀 HTTP GraphQL ready at http://localhost:${PORT}/graphql`);
console.log(`🚀 WS GraphQL ready at ws://localhost:${PORT}/graphql`);