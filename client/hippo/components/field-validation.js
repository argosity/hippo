export default function FieldValidation(props, propName) {
    if (!props[propName]) {
        return new Error(`${propName} is missing`);
    } if (!props[propName][props.name]) {
        return new Error(`${propName} does not have ${props.name}`);
    }
}
