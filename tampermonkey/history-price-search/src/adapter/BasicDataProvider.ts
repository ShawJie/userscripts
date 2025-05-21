export default abstract class BasicDataProvider {
    name: String;
    link: String;

    constructor(name: String, link: String) {
        this.name = name;
        this.link = link;
    }

    abstract load(): Promise<void>;
}
