export const users = [
    {
        id: 'u1',
        email: 'demo@example.com',
        password: 'password123',
    },
];

export const todos = [
    {
        id: 't1',
        title: 'Learn GraphQL basics',
        description: 'Understand query, mutation, and subscription',
        completed: false,
        createdAt: new Date().toISOString(),
        ownerId: 'u1',
    },
];