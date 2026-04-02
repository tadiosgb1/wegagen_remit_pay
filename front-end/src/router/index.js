import { createRouter, createWebHistory } from "vue-router";
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
        path: "apicredentials",
        name: "IntegrationSettings-view",
        component: () => import('../views/closed/ApiCredentials/IntegrationSettingsView.vue'),
      },
      {
        path: "apicredentials/add",
        name: "IntegrationSettings-add",
        component: () => import('../views/closed/ApiCredentials/AddIntegrationSettings.vue'),
      },
      {
        path: "apicredentials/edit/:id",
        name: "IntegrationSettings-edit",
        component: () => import('../views/closed/ApiCredentials/EditIntegrationSettings.vue'),
        props: true,
      },
      {
        path: "apicredentials/detail/:id",
        name: "IntegrationSettings-detail",
        component: () => import('../views/closed/ApiCredentials/IntegrationSettingsDetail.vue'),
        props: true,
      },

      {
        path: "remittances",
        name: "Transactions-view",
        component: () => import('../views/closed/Remittances/TransactionsView.vue'),
      },
      {
        path: "remittances/add",
        name: "Transactions-add",
        component: () => import('../views/closed/Remittances/AddTransactions.vue'),
      },
      {
        path: "remittances/edit/:id",
        name: "Transactions-edit",
        component: () => import('../views/closed/Remittances/EditTransactions.vue'),
        props: true,
      },
      {
        path: "remittances/detail/:id",
        name: "Transactions-detail",
        component: () => import('../views/closed/Remittances/TransactionsDetail.vue'),
        props: true,
      },

      {
        path: "systemusers",
        name: "Users-view",
        component: () => import('../views/closed/SystemUsers/UsersView.vue'),
      },
      {
        path: "systemusers/add",
        name: "Users-add",
        component: () => import('../views/closed/SystemUsers/AddUsers.vue'),
      },
      {
        path: "systemusers/edit/:id",
        name: "Users-edit",
        component: () => import('../views/closed/SystemUsers/EditUsers.vue'),
        props: true,
      },
      {
        path: "systemusers/detail/:id",
        name: "Users-detail",
        component: () => import('../views/closed/SystemUsers/UsersDetail.vue'),
        props: true,
      },

      {
        path: "roles",
        name: "Role-view",
        component: () => import('../views/closed/Roles/RoleView.vue'),
      },
      {
        path: "roles/add",
        name: "Role-add",
        component: () => import('../views/closed/Roles/AddRole.vue'),
      },
      {
        path: "roles/edit/:id",
        name: "Role-edit",
        component: () => import('../views/closed/Roles/EditRole.vue'),
        props: true,
      },
      {
        path: "roles/detail/:id",
        name: "Role-detail",
        component: () => import('../views/closed/Roles/RoleDetail.vue'),
        props: true,
      },

      {
        path: "audittrails",
        name: "AuditLogs-view",
        component: () => import('../views/closed/AuditTrails/AuditLogsView.vue'),
      },
      {
        path: "audittrails/add",
        name: "AuditLogs-add",
        component: () => import('../views/closed/AuditTrails/AddAuditLogs.vue'),
      },
      {
        path: "audittrails/edit/:id",
        name: "AuditLogs-edit",
        component: () => import('../views/closed/AuditTrails/EditAuditLogs.vue'),
        props: true,
      },
      {
        path: "audittrails/detail/:id",
        name: "AuditLogs-detail",
        component: () => import('../views/closed/AuditTrails/AuditLogsDetail.vue'),
        props: true,
      },

      {
        path: "kycapplications",
        name: "KycManagement-view",
        component: () => import('../views/closed/KYCApplications/KycManagementView.vue'),
      },
      {
        path: "kycapplications/add",
        name: "KycManagement-add",
        component: () => import('../views/closed/KYCApplications/AddKycManagement.vue'),
      },
      {
        path: "kycapplications/edit/:id",
        name: "KycManagement-edit",
        component: () => import('../views/closed/KYCApplications/EditKycManagement.vue'),
        props: true,
      },
      {
        path: "kycapplications/detail/:id",
        name: "KycManagement-detail",
        component: () => import('../views/closed/KYCApplications/KycManagementDetail.vue'),
        props: true,
      },

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
        path: "first-dash", name: "first-dash",
        component: first_dash,
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
