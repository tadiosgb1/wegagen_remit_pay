import { createRouter, createWebHistory } from "vue-router";
import Home from '../views/opened/landing/Home.vue'

import SendSMS from  '../views/opened/landing/apidocs/SendSMS.vue'
import BulkSend from "../views/opened/landing/apidocs/BulkSend.vue";
import Otp from  '../views/opened/landing/apidocs/OTP.vue'
import Verify from  '../views/opened/landing/apidocs/Verify.vue'
import Balance from  '../views/opened/landing/apidocs/Balance.vue'
import Status from  '../views/opened/landing/apidocs/Status.vue'
import About from  '../views/opened/landing/about.vue'
import Products from  '../views/opened/landing/products.vue'
import Pricing from  '../views/opened/landing/plans.vue'

import Login from '../views/opened/auth/login.vue'

import ResetPassword from '../views/opened/auth/ResetPassword.vue'
import ForgotPasssword from '../views/opened/auth/forgotPassword.vue'
import ActivateEmailMessage from '../views/opened/landing/activateEmailMessage.vue'
import Registration from '../views/opened/auth/registration.vue'
import ForgotPassword from '../views/opened/auth/forgotPassword.vue';
import Reset from '../views/opened/auth/reset.vue';
import AccessDenied from "../views/opened/auth/accessDenied.vue";
import first_dash from '../views/closed/first_dash.vue'
import dashboard from '../views/closed/dashboard.vue'


import RoleView from '../views/closed/Roles/RoleView.vue'
import PermissionView from '../views/closed/Permissions/PermissionView.vue'




const routes = [
  {
    path: "/", name: "/",
    component: Login,
    meta:
      { requiresGuest: true }
  },
  {
    path: "/login", name: "login",
    component: Login,
    meta:
      { requiresGuest: true }
  },
  {
    path: "/register", name: "register",
    component: Registration,
    meta:
      { requiresGuest: true }
  },


  {
    path: "/email-activate-message", name: "email-activate-message",
    component: ActivateEmailMessage,
    meta:
      { requiresGuest: true }
  },
  // router/index.js
   {
    path: '/forgot-password',
    name: 'ForgotPassword',
    component: ForgotPasssword,
    props: true
  },
    {
      path: "/:lang/reset-password",
      name: "ResetPassword",
      component: ResetPassword,
      props: true, // passes route params as props
    },
  ,
  {
    path: "/dashboard", name: "dashboard",
    component: dashboard,
    meta:
      { requiresGuest: true },
      children: [
      {
        path: "permissions",
        name: "Permission-view",
        component: () => import('../views/closed/Permissions/PermissionView.vue'),
      },
      {
        path: "permissions/add",
        name: "Permission-add",
        component: () => import('../views/closed/Permissions/AddPermission.vue'),
      },
      {
        path: "permissions/edit/:id",
        name: "Permission-edit",
        component: () => import('../views/closed/Permissions/EditPermission.vue'),
        props: true,
      },
      {
        path: "permissions/detail/:id",
        name: "Permission-detail",
        component: () => import('../views/closed/Permissions/PermissionDetail.vue'),
        props: true,
      },

     

      

     
     

      

     

      
     
      
    

     
   

      {
        path: "users",
        name: "Users-view",
        component: () => import('../views/closed/users/UsersView.vue'),
      },
      {
        path: "users/add",
        name: "Users-add",
        component: () => import('../views/closed/users/AddUsers.vue'),
      },
      {
        path: "users/edit/:id",
        name: "Users-edit",
        component: () => import('../views/closed/users/EditUsers.vue'),
        props: true,
      },
      {
        path: "users/detail/:id",
        name: "Users-detail",
        component: () => import('../views/closed/users/UsersDetail.vue'),
        props: true,
      },

      {
        path: "first-dash", name: "first-dash",
        component: first_dash,
      },

      {
        path: "role-view", name: "Role-view",
        component: RoleView,
      },

        {
        path: "permission-view", name: "Permission-view",
        component: PermissionView,
      },
       

         
    ]
  },
  { path: "/forgot-password", name: "forgotPassword", component: ForgotPassword },
  { path: "/reset/:token", name: "reset", component: Reset, meta: { requiresGuest: true } },
  { path: "/:pathMatch(.*)*", name: "accessDenied", component: AccessDenied, meta: { requiresGuest: true } },
];

const router = createRouter({
  // mode: 'hash',
  history: createWebHistory(),
  routes, // ✅ no spread needed
});

router.beforeEach((to, from, next) => {
  const isAuthenticated = localStorage.getItem("token");
  const userRole = localStorage.getItem("role");

  const requiresAuth = to.matched.some(record => record.meta.requiresAuth);
  const requiresGuest = to.matched.some(record => record.meta.requiresGuest);
  const requiredRole = to.meta.role;

  if (requiresAuth) {
    if (!isAuthenticated) {
      next("/login");
    } else if (requiredRole && userRole !== requiredRole) {
      localStorage.clear();
      next("/login");
    } else {
      next();
    }
  } else if (requiresGuest) {
    next();
  } else {
    next();
  }
});

export default router;
