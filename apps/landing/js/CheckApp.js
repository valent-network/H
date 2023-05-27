function CheckApp() {
  const API_HOST = "https://recar.io";

  return {
    init() {
      if (this.token){ this.getApproxStats() }
    },
    requestSMS() {
      this.isLoading = true;
      fetch(`${API_HOST}/api/v1/sessions`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ phone_number: this.phone })
      }).then(response => {
        if (response.ok) {
          this.error = null;
          response.json().then(data => {
            this.isLoading = false;
            this.authStep = 1;
          })
        } else if (response.status === 422) {
          response.json().then(data => {
            this.error = data.message;
            this.isLoading = false;
          });
        } else {
          throw new Error(response.statusText)
        }
      }).catch(error => {
        this.error = error;
        this.isLoading = false;
      })
    },
    submitCode() {
      this.isLoading = true;
      fetch(`${API_HOST}/api/v1/sessions`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ phone_number: this.phone.replace(/^\+380(\d+)$/gi, "$1"), verification_code: this.code, device_id: this.deviceId })
      }).then(response => {
        if (response.ok) {
          this.error = null;
          response.json().then(data => {
            this.isLoading = false;
            this.authStep = 2;
            this.token = data.access_token;
            Alpine.nextTick(() => this.getApproxStats());
          });
        } else if (response.status === 422) {
          response.json().then(data => {
            this.code = null;
            this.error = data.message;
            this.isLoading = false;
          });
      } else {
          throw new Error(response.statusText)
        }
      }).catch(error => {
        this.error = error;
        this.isLoading = false
      })
    },
    reset() {
      this.authStep = 0;
      this.code = null;
      this.phone = "+380",
      this.stats = null;
      this.token = null;
      this.error = null;
      this.isLoading = false;
    },
    logout() {
      if (!this.token) {
        this.reset();
        return;
      }
      this.isLoading = true;
      fetch(`${API_HOST}/api/v1/sessions`, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ access_token: this.token })
      }).then(response => response).then(data => {
        this.isLoading = false;
        this.reset();

      }).catch(error => {
        this.error = error;
        this.isLoading = false;
      });
    },
    getApproxStats() {
      this.isLoading = true;
      fetch(`${API_HOST}/api/v1/approximate_stats?access_token=${this.token}`).then(response => {
        if (response.ok) {
          response.json().then(data => {
            this.stats = data;
            this.isLoading = false;
          });
        } else if (response.status === 401) {
          this.reset();
          this.error = "Не авторизовано, будь ласка, введіть свій телефон"
        } else {
          throw new Error(response.statusText)
        }
      }).catch(error => {
        this.error = error;
        this.isLoading = false;
      });
    },
    uploadContact(phone) {
      this.isLoading = true;
      fetch(`${API_HOST}/api/v1/user_contacts`, {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-User-Access-Token": this.token },
        body: JSON.stringify({phone})
      }).then(response => {
        if (response.ok) {
          this.getApproxStats();
        } else if (response.status === 422) {
          response.json().then(data => {
            this.error = data.errors;
            this.isLoading = false;
          });
        } else {
          throw new Error(response.statusText)
        }
      }).catch(error => {
        this.error = error;
        this.isLoading = false;
      });
    },
    authStep: Alpine.$persist(0),
    isLoading: false,
    phone: Alpine.$persist("+380"),
    code: Alpine.$persist(null),
    token: Alpine.$persist(null),
    deviceId: Alpine.$persist(Math.random().toString(36).substr(2, 9)),
    error: null,
    stats: null,
  }
}