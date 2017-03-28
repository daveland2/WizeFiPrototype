export interface IProfile {
    name: string;
    age: string;
}

export class CProfile {

    constructor (public profile: IProfile) { }

}