// src/utils/schema.js
export const formSchema = {
    login: {
      fields: {
        username: {
          for:"username",
          id:"username",
          name: 'username',
          label: 'Username',
          type: 'text',
          placeholder: 'Enter your username',
          rules: {
            required: true,
          },
        },
        password: {
          name: 'password',
          for:"password",
          id:"password",
          label: 'Password',
          type: 'password',
          placeholder: 'Enter your password',
          rules: {
            required: true,
          },
        },
      },
    },
  };
  