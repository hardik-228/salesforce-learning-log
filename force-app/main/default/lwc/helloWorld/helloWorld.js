import { LightningElement, wire } from 'lwc';
import getGreeting from '@salesforce/apex/HelloWorldController.getGreeting';

export default class HelloWorld extends LightningElement {
    greeting = 'Hello World from JS!';

    @wire(getGreeting)
    apexGreeting;
}
