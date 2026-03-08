import { PubSub } from 'graphql-subscriptions';

export const pubsub = new PubSub();

export const EVENTS = {
    TODO_ADDED: 'TODO_ADDED',
    TODO_UPDATED: 'TODO_UPDATED',
    TODO_DELETED: 'TODO_DELETED',
};