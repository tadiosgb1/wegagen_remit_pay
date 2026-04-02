
import axios from "axios";
import ApiService from "../Services/ApiService.js";
export default {
  data() {
    return {
      currentStep: 1,
      permitRegisterOnline: false,
      days: Array.from({ length: 31 }, (_, i) => i + 1),
      months: [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
      ],
      years: [],
      username: "",
      password: "",
      confirmPassword: "",
      name: {
        firstName: "",
        middleName: "",
        lastName: "",
      },
      address: {
        country: "",
        state: "",
        zone: "",
        wereda: "",
        kebelle: "",
        city: "",
      },
      contactInfo: {
        email: "",
        phoneNumber: "",
      },
      dateOfBirth: {
        day: "",
        month: "",
        year: "",
      },
      gender: "",

      passwordMismatch: false,
      UsernameEmailTaken: false,
      UserNotFound: false,
      showLogin: true,
      showRegistration: false,
      isScrolled: false,
      showDropdown: false,
      showSecondDropdown: false,
      showUnderline: {
        more: false,
      },
      showMedicalQADropdown: false,
      isScrolledDropdown: false,
      usernameIsRequired: false,
      passwordIsRequired: false,
    };
  },
  mounted() {
    window.addEventListener("scroll", this.handleScroll);
    this.years = this.generateYearsArray(1914, 100).concat(
      this.generateYearsArray(2024, 100)
    );
  },
  beforeUnmount() {
    window.removeEventListener("scroll", this.handleScroll);
  },
  created() {
    this.apiClient = axios.create({
      baseURL: "http://localhost:8081", // Set your base URL here
    });

    
  },
  methods: {
    nextStep() {
      this.currentStep++;
      console.log("current step", this.currentStep);
    },
    previousStep() {
      this.currentStep--;
    },
    generateYearsArray(startYear, numYears) {
      const years = [];
      for (let i = 0; i < numYears; i++) {
        years.push(startYear + i);
      }
      return years;
    },
    checkApiService() {
      ApiService.chackService();
    },

    ToggleLoginRegister() {
      this.showLogin = false;
      this.showRegistration = true;
    },

    toggleDropdown() {
      this.showDropdown = !this.showDropdown;
    },
    toggleshowSecondDropdown(value) {
      this.showSecondDropdown = value;
    },
    toggleUnderline(key, shouldShow) {
      this.showUnderline[key] = shouldShow;
    },
    handleScroll() {
      this.isScrolled = window.scrollY > 130;
    },
    showLoginForm() {
      this.showLogin = true;
      this.showRegistration = false;
    },
    showRegistrationForm() {
      this.showLogin = false;
      this.showRegistration = true;
    },
    login() {
      console.log("username", this.username);
      const userData = {
        username: this.username,
        password: this.password,
      };
      console.log(userData);
      if (this.username.trim() === "") {
        this.usernameIsRequired = true;
        return;
      }

      // Check if password is empty
      if (this.password.trim() === "") {
        this.passwordIsRequired = true;
        return;
      }

      console.log("login called");
      this.apiClient.post("/api/auth/signin", userData).then((response) => {
        const { roles, accessToken, id } = response.data;
        if (response.data.status === 1) {
          if (roles.includes("ROLE_ADMIN")) {
            const userId = id;
            this.$store.dispatch("login", { accessToken });
            this.$store.dispatch("commitId", { userId });
            // console.log("response.data._id:",id);
            this.$router.push("/admindashboard");

          } else if (roles.includes("ROLE_USER")) {
            this.$store.dispatch("login", { accessToken });
            this.$store.dispatch("commitId", { id });
            this.$router.push("/userdashboard");
          } else {
            this.$store.dispatch("login", { accessToken });
            this.$store.dispatch("commitId", { id });
            this.$router.push("/doctordashboard");
          }
        } else {
          this.UserNotFound = true;
        }
      });
    },
    register() {
      if (this.password !== this.confirmPassword) {
        console.log(this.password);
        console.log(this.confirmPassword);
        this.passwordMismatch = true;
        return;
      } else {
        const userData = {
          username: this.username,
          password: this.password,
          address: this.address,
          name: this.name,
          dateOfBirth: this.dateOfBirth,
          gender: this.gender,
          contactInfo: this.contactInfo,
        };
        console.log("UserData", userData);
        this.apiClient
          .post("/api/auth/signup", userData)
          .then((response) => {
            const { roles, accessToken, id } = response.data;

            if (response.data.status === 1) {
              if (roles.includes("ROLE_ADMIN")) {
                this.$store.dispatch("login", { accessToken });
                this.$store.dispatch("commitId", { id });

                this.$router.push("/admindashboard");
              } else if (roles.includes("ROLE_USER")) {
                this.$store.dispatch("login", { accessToken });
                this.$store.dispatch("commitId", { id });
                this.$router.push("/userdashboard");
              } else {
                this.$store.dispatch("login", { accessToken });
                this.$store.dispatch("commitId", { id });
                this.$router.push("/doctordashboard");
              }
            } else {
              this.UsernameEmailTaken = true;
            }
          })
          .catch((error) => {
            console.error(error);
          });
      }
    },
  },
};

