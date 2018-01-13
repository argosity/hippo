import React from 'react'; // eslint-disable-line no-unused-vars
import PropTypes from 'prop-types';
import classnames from 'classnames';
import { Box } from 'grommet';
import { Close } from 'grommet-icons';
import StatusIcon from './icon/status';

export default function Notification({
    size, className, message, children, status, closer, onClose, ...otherProps
}) {
    let statusNode;
    if (status) {
        statusNode = (
            <StatusIcon className="notification-status" value={status} size={size} />
        );
    }

    const classes = classnames(
        'notification',
        `notification-status-${status.toLowerCase()}`,
        className,
    );

    let closerNode;
    if ('object' === typeof closer) {
        closerNode = closer;
    } else if (onClose && closer) {
        closerNode = (
            <Button
                plain={true} onClick={onClose}
                icon={<Close className="notification-close" />}
            />
        );
    }

    return (
        <Box
            {...otherProps}
            className={classes}
            pad='small' direction='row' align='start'
            responsive={false}
        >
            <Box pad='small'>
                {statusNode}
            </Box>
            <Box flex={true} pad='small'>
                <span className="notification-message">{message}</span>
                {children}
            </Box>
            {closerNode}
        </Box>
    );
}

Notification.propTypes = {
    size: PropTypes.oneOf(['small', 'medium', 'large']),
    status: PropTypes.string,
    ...Box.propTypes,
};

Notification.defaultProps = {
    status: 'unknown',
    pad: 'medium',
};


//
// import Box from './Box';
// import Value from './Value';
//
// import Button from './Button';
// import StatusIcon from './icons/Status';
// import CloseIcon from './icons/base/Close';
// import Props from '../utils/Props';
// import CSSClassnames from '../utils/CSSClassnames';
// import Announcer from '../utils/Announcer';
// import { checkDarkBackground } from '../utils/DOM';
//
// const CLASS_ROOT = CSSClassnames.NOTIFICATION;
// const BACKGROUND_COLOR_INDEX = CSSClassnames.BACKGROUND_COLOR_INDEX;
//
// export default class Notification extends Component {
//
//     constructor () {
//         super();
//         this._announce = this._announce.bind(this);
//         this._setDarkBackground = this._setDarkBackground.bind(this);
//         this.state = {};
//     }
//
//     componentDidMount () {
//         this._announce();
//         // Measure the actual background color brightness to determine whether
//         // to set a dark or light context.
//         this._setDarkBackground();
//     }
//
//     componentWillReceiveProps (nextProps) {
//         if (nextProps.status !== this.props.status) {
//             this.setState({ updateDarkBackground: true });
//         }
//     }
//
//     componentDidUpdate () {
//         this._announce();
//         if (this.state.updateDarkBackground) {
//             this.setState({ updateDarkBackground: false });
//             this._setDarkBackground();
//         }
//     }
//
//     componentWillUnmount () {
//         if (this._checkBackground) {
//             this._checkBackground.stop();
//         }
//     }
//
//     _setDarkBackground () {
//         const { status } = this.props;
//         const container = findDOMNode(this._containerRef);
//         if (this._checkBackground) {
//             this._checkBackground.stop();
//         }
//         this._checkBackground = checkDarkBackground(status, container,
//             (darkBackground) => this.setState({ darkBackground }));
//     }
//
//     _announce () {
//         const { announce, message } = this.props;
//         const { intl } = this.context;
//         if (announce) {
//             const notificationMessage = Intl.getMessage(intl, 'Notification');
//             Announcer.announce(`${notificationMessage}: ${message}`);
//         }
//     }
//
//     _backgroundContextClass (darkBackground) {
//         let result;
//         if (undefined === darkBackground) {
//             result = `${BACKGROUND_COLOR_INDEX}--pending`;
//         } else if (darkBackground) {
//             result = `${BACKGROUND_COLOR_INDEX}--dark`;
//         } else {
//             result = `${BACKGROUND_COLOR_INDEX}--light`;
//         }
//         return result;
//     }
//
//     render () {
//         const {
//             children, className, closer, context, message,
//             onClose, size, state, status
//         } = this.props;
//         const { intl } = this.context;
//         const { darkBackground } = this.state;
//         const classes = classnames(
//             CLASS_ROOT,
//             `${CLASS_ROOT}--status-${status.toLowerCase()}`,
//             `${BACKGROUND_COLOR_INDEX}-${status.toLowerCase()}`,
//             this._backgroundContextClass(darkBackground),
//             {
//                 [`${CLASS_ROOT}--${size}`]: size
//             },
//             className
//         );
//
//         let statusNode;
//         if (status) {
//             statusNode = (
//                 <StatusIcon className={`${CLASS_ROOT}__status`}
//                             value={status} size={size} />
//             );
//         }
//
//         let stateNode;
//         if (state) {
//             stateNode = (
//                 <div className={`${CLASS_ROOT}__state`}>{state}</div>
//             );
//         }
//
//         let closerNode;
//         if (typeof closer === 'object') {
//             closerNode = closer;
//         } else if (onClose && closer) {
//             closerNode = (
//                 <Button plain={true} onClick={onClose}
//                         icon={<CloseIcon
//                                   className={`${CLASS_ROOT}__close`} />}
//                         a11yTitle={
//                             Intl.getMessage(intl, 'Close Notification')
//                         } />
//             );
//         }
//
//         const boxProps = Props.pick(this.props, Object.keys(Box.propTypes));
//         const restProps =
//             Props.omit(this.props, Object.keys(Notification.propTypes));
//         boxProps.announce = false;
//         const fullBox =
//             boxProps.hasOwnProperty('full') ? boxProps.full : undefined;
//
//         if (size && typeof size === 'string') {
//             // don't transfer size to Box since it means something different
//             delete boxProps.size;
//         }
//         /*
//            <Animate enter={{ animation: 'fade', duration: 1000 }}
//            leave={{ animation: 'fade', duration: 1000 }}>
//            </Animate>
//          */
//         return (
//             <Box ref={(ref) => this._containerRef = ref}
//                  {...restProps} {...boxProps} className={classes}
//                  pad='small' direction='row' align='start' responsive={false}
//                  full={fullBox}>
//                 <Box pad='small'>
//                     {statusNode}
//                 </Box>
//                 <Box flex={true} pad='small'>
//                     <span className={`${CLASS_ROOT}__message`}>
//                         {message}
//                     </span>
//                     {context}
//                     {stateNode}
//
//                     {children}
//                 </Box>
//                 {closerNode}
//             </Box>
//         );
//     }
// }
