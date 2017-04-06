import { Injectable } from '@angular/core';
import { ApplicationRef } from '@angular/core';

@Injectable()
export class ManageMessages {

    constructor (private ref: ApplicationRef) { }

    public update(messages: string[], message:string)
    {
        if (message != '') messages.push(message);
        this.ref.tick();  // force change detection so messages will appear on screen
    }

}   // class ConfigValues