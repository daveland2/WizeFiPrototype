/*
The need for this machinery has been eliminated by utilizing the "fat arrow" notation for defining functions in order to get a "static" scope for the "this" notation.

This solved the problem where change detection was not working properly when displaying messages.
*/

import { Injectable, ApplicationRef } from '@angular/core';

@Injectable()
export class ManageMessages {

    constructor (private ref: ApplicationRef) { }

    public update(messages: string[], message:string)
    {
    	if (message != '') messages.push(message);
	    this.ref.tick();  // force change detection so messages will appear on screen
    }

}   // class ConfigValues