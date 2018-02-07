import styled from 'styled-components';

const TextEditorWrapper = styled.div`
    flex: 1;
    min-height: 400px;
    margin: 0.8em;
    position: relative;
    display: flex;
    flex-direction: column;
    .ql-editor {
        flex: 1;
    }
.saving-image {
    position: absolute;
    width: 100%;
    height: 100%;
    background-color: rgba(255, 255, 255, 0.3);
    &:after {
        content: "Saving image…";
        font-weight: bold;
        display: inline-block;
        font-style: italic;
        top: 40%;
        text-align: center;
        font-size: 1.8rem;
        position: absolute;
        border: 1px solid lightgrey;
        left: 40%;
        min-width: 20%;
    }
}

`;

export default TextEditorWrapper;
