import { Application } from "@hotwired/stimulus";

import AlertController from "./alert_controller"

const application = Application.start();
application.register("alert", AlertController);
