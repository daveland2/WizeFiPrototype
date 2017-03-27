export interface IProfile {
    name: string;
    age: number;
}

export class CProfile {

    constructor (public profile: IProfile) { }

}