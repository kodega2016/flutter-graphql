import { GraphQLError } from 'graphql';
import { withFilter } from 'graphql-subscriptions';
import { pubsub, EVENTS } from './pubsub.js';
import { users, todos } from '../data/db.js';
import { generateToken } from '../auth/jwt.js';

function requireAuth(context) {
    if (!context.user) {
        throw new GraphQLError('Unauthorized', {
            extensions: { code: 'UNAUTHENTICATED' },
        });
    }
    return context.user;
}

export const typeDefs = `#graphql
  type User {
    id: ID!
    email: String!
  }

  type Todo {
    id: ID!
    title: String!
    description: String!
    completed: Boolean!
    createdAt: String!
    ownerId: ID!
  }

  type AuthPayload {
    accessToken: String!
    user: User!
  }

  type Query {
    me: User
    todos: [Todo!]!
  }

  type Mutation {
    register(email: String!, password: String!): AuthPayload!
    login(email: String!, password: String!): AuthPayload!
    addTodo(title: String!, description: String!): Todo!
    toggleTodo(id: ID!): Todo!
    deleteTodo(id: ID!): Boolean!
  }

  type Subscription {
    todoAdded: Todo!
    todoUpdated: Todo!
    todoDeleted: ID!
  }
`;

export const resolvers = {
    Query: {
        me: (_, __, context) => {
            return context.user || null;
        },

        todos: (_, __, context) => {
            const user = requireAuth(context);
            return todos.filter((todo) => todo.ownerId === user.id);
        },
    },

    Mutation: {
        register: (_, { email, password }) => {
            const existingUser = users.find((u) => u.email === email);
            if (existingUser) {
                throw new GraphQLError('User already exists', {
                    extensions: { code: 'BAD_USER_INPUT' },
                });
            }

            const newUser = {
                id: `u${users.length + 1}`,
                email,
                password,
            };

            users.push(newUser);

            const accessToken = generateToken(newUser);

            return {
                accessToken,
                user: newUser,
            };
        },

        login: (_, { email, password }) => {
            const user = users.find(
                (u) => u.email === email && u.password === password
            );

            if (!user) {
                throw new GraphQLError('Invalid credentials', {
                    extensions: { code: 'UNAUTHENTICATED' },
                });
            }

            const accessToken = generateToken(user);

            return {
                accessToken,
                user,
            };
        },

        addTodo: async (_, { title, description }, context) => {
            const user = requireAuth(context);

            const newTodo = {
                id: `t${todos.length + 1}`,
                title,
                description,
                completed: false,
                createdAt: new Date().toISOString(),
                ownerId: user.id,
            };

            todos.push(newTodo);

            await pubsub.publish(EVENTS.TODO_ADDED, {
                todoAdded: newTodo,
            });

            return newTodo;
        },

        toggleTodo: async (_, { id }, context) => {
            const user = requireAuth(context);

            const todo = todos.find((t) => t.id === id && t.ownerId === user.id);

            if (!todo) {
                throw new GraphQLError('Todo not found', {
                    extensions: { code: 'NOT_FOUND' },
                });
            }

            todo.completed = !todo.completed;

            await pubsub.publish(EVENTS.TODO_UPDATED, {
                todoUpdated: todo,
            });

            return todo;
        },

        deleteTodo: async (_, { id }, context) => {
            const user = requireAuth(context);

            const index = todos.findIndex((t) => t.id === id && t.ownerId === user.id);

            if (index === -1) {
                throw new GraphQLError('Todo not found', {
                    extensions: { code: 'NOT_FOUND' },
                });
            }

            const deleted = todos[index];
            todos.splice(index, 1);

            await pubsub.publish(EVENTS.TODO_DELETED, {
                todoDeleted: deleted.id,
                ownerId: deleted.ownerId,
            });

            return true;
        },
    },

    Subscription: {
        todoAdded: {
            subscribe: withFilter(
                () => pubsub.asyncIterator(EVENTS.TODO_ADDED),
                (payload, variables, context) => {
                    return payload.todoAdded.ownerId === context.user.id;
                }
            ),
        },
        todoUpdated: {
            subscribe: withFilter(
                () => pubsub.asyncIterator(EVENTS.TODO_UPDATED),
                (payload, variables, context) => {
                    return payload.todoUpdated.ownerId === context.user.id;
                }
            ),
        },
        todoDeleted: {
            subscribe: withFilter(
                () => pubsub.asyncIterator(EVENTS.TODO_DELETED),
                (payload, variables, context) => {
                    return payload.ownerId === context.user.id;
                }
            ),
        },
    },
};