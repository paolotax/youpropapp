// Generated by IB v0.3.5 gem. Do not edit it manually
// Run `rake ib:open` to refresh

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface ParserError: StandardError
@end

@interface NSNotificationCenter
-(IBAction) observers;
-(IBAction) unobserve:(id) observer;

@end

@interface NSURLRequest
-(IBAction) to_s;

@end

@interface Camera
-(IBAction) initialize:(id) location;
-(IBAction) location;
-(IBAction) imagePickerControllerDidCancel:(id) picker;
-(IBAction) picker;
-(IBAction) dismiss;
-(IBAction) camera_device;
-(IBAction) media_type_to_symbol:(id) media_type;
-(IBAction) symbol_to_media_type:(id) symbol;
-(IBAction) error:(id) type;

@end

@interface UIAlertView
-(IBAction) style;
-(IBAction) cancel_button_index;

@end

@interface ClickedButton
-(IBAction) willPresentAlertView:(id) alert;
-(IBAction) didPresentAlertView:(id) alert;
-(IBAction) alertViewCancel:(id) alert;
-(IBAction) alertViewShouldEnableFirstOtherButton:(id) alert;
-(IBAction) plain_text_field;
-(IBAction) secure_text_field;
-(IBAction) login_text_field;
-(IBAction) password_text_field;

@end

@interface InvalidURLError: StandardError
@end

@interface InvalidFileError: StandardError
@end

@interface Layout
-(IBAction) metrics:(id) metrics;
-(IBAction) subviews:(id) subviews;
-(IBAction) view:(id) view;
-(IBAction) horizontal:(id) horizontal;
-(IBAction) vertical:(id) vertical;
-(IBAction) strain;

@end

@interface NSMutableURLRequest
-(IBAction) url;
-(IBAction) content_type;
-(IBAction) parameters;

@end

@interface NSString
-(IBAction) to_url;

@end

@interface NSURL
-(IBAction) to_url;

@end

@interface UIImageView
-(IBAction) url;

@end

@interface HTTPResult
-(IBAction) body;

@end

@interface ClientDSL
-(IBAction) initialize:(id) client;
-(IBAction) authorization:(id) options;
-(IBAction) operation:(id) operation;
-(IBAction) parameter_encoding:(id) encoding;

@end

@interface AFHTTPClient
-(IBAction) authorization;
-(IBAction) initialize:(id) client;
-(IBAction) delete:(id) header;
-(IBAction) headers;
-(IBAction) dummy;

@end

@interface HeaderWrapper
-(IBAction) initialize:(id) client;
-(IBAction) delete:(id) header;
-(IBAction) headers;
-(IBAction) dummy;

@end

@interface UIImage
-(IBAction) imageNamed568:(id) name;
-(IBAction) imageNamed:(id) name;

@end

@interface AnimationChain
-(IBAction) chains;
-(IBAction) start_chain:(id) chain;
-(IBAction) stop_chain:(id) chain;
-(IBAction) initialize;
-(IBAction) wait:(id) duration;
-(IBAction) do_next;
-(IBAction) start;
-(IBAction) loop:(id) times;
-(IBAction) stop;
-(IBAction) abort;

@end

@interface UIView
-(IBAction) show;
-(IBAction) hide;
-(IBAction) shake:(id) options;
-(IBAction) dummy;

@end

@interface Anonymous: Hash
-(IBAction) to_object;
-(IBAction) each;

@end

@interface NSObject
-(IBAction) to_object;

@end

@interface NSDictionary
-(IBAction) to_object;

@end

@interface AnonymousArray: Array
-(IBAction) first;
-(IBAction) last;
-(IBAction) to_object;

@end

@interface NSArray
-(IBAction) to_object;

@end

@interface NSString
-(IBAction) bold:(id) size;
-(IBAction) italic:(id) size;
-(IBAction) monospace:(id) size;
-(IBAction) underline:(id) underline_style;
-(IBAction) nsattributedstring:(id) attributes;

@end

@interface NSMutableString
-(IBAction) nsattributedstring:(id) attributes;
-(IBAction) dummy;

@end

@interface NSAttributedString
-(IBAction) dummy;
-(IBAction) to_s;
-(IBAction) bold:(id) size;
-(IBAction) italic:(id) size;
-(IBAction) underline;
-(IBAction) font:(id) value;
-(IBAction) paragraph_style:(id) value;
-(IBAction) foreground_color:(id) value;
-(IBAction) underline_style:(id) value;
-(IBAction) background_color:(id) value;
-(IBAction) ligature:(id) value;
-(IBAction) kern:(id) value;
-(IBAction) stroke_width:(id) value;
-(IBAction) stroke_color:(id) value;
-(IBAction) strikethrough_style:(id) value;
-(IBAction) shadow:(id) value;
-(IBAction) vertical_glyph_form:(id) value;
-(IBAction) with_attributes:(id) attributes;
-(IBAction) nsattributedstring;

@end

@interface NSMutableAttributedString
-(IBAction) with_attributes:(id) attributes;

@end

@interface Symbol
-(IBAction) awesome_icon:(id) options;

@end

@interface Fixnum
-(IBAction) uicolor:(id) alpha;

@end

@interface NSArray
-(IBAction) uicolor:(id) alpha;

@end

@interface NSString
-(IBAction) uicolor:(id) alpha;

@end

@interface Symbol
-(IBAction) uicolor:(id) alpha;

@end

@interface UIColor
-(IBAction) uicolor:(id) alpha;
-(IBAction) cgcolor;
-(IBAction) invert;
-(IBAction) red;
-(IBAction) green;
-(IBAction) blue;
-(IBAction) alpha;
-(IBAction) to_i;
-(IBAction) to_a;
-(IBAction) hex;
-(IBAction) css_name;
-(IBAction) system_name;

@end

@interface UIImage
-(IBAction) uicolor:(id) alpha;

@end

@interface Symbol
-(IBAction) uidevice;
-(IBAction) uideviceorientation;
-(IBAction) uiinterfaceorientation;
-(IBAction) uiinterfacemask;
-(IBAction) uiautoresizemask;
-(IBAction) uireturnkey;
-(IBAction) uikeyboardtype;
-(IBAction) uitextalignment;
-(IBAction) uilinebreakmode;
-(IBAction) uibaselineadjustment;
-(IBAction) uibordertype;
-(IBAction) nsdatestyle;
-(IBAction) nsnumberstyle;
-(IBAction) uistatusbarstyle;
-(IBAction) uibarmetrics;
-(IBAction) uibarbuttonitem;
-(IBAction) uibarbuttonstyle;
-(IBAction) uibuttontype;
-(IBAction) uicontrolstate;
-(IBAction) uicontrolevent;
-(IBAction) uiactivityindicatorstyle;
-(IBAction) uisegmentedstyle;
-(IBAction) uidatepickermode;
-(IBAction) uicontentmode;
-(IBAction) uianimationcurve;
-(IBAction) uitablestyle;
-(IBAction) uitablerowanimation;
-(IBAction) uitablecellstyle;
-(IBAction) uitablecellaccessorytype;
-(IBAction) uitablecellselectionstyle;
-(IBAction) uitablecellseparatorstyle;
-(IBAction) uialertstyle;
-(IBAction) uiactionstyle;
-(IBAction) uiimagesource;
-(IBAction) uiimagecapture;
-(IBAction) uiimagecamera;
-(IBAction) uiimagequality;
-(IBAction) catimingfunction;
-(IBAction) cglinecap;
-(IBAction) cglinejoin;
-(IBAction) uigesturerecognizerstate;

@end

@interface SugarCubeNotFoundException: Exception
@end

@interface NSError
-(IBAction) to_s;

@end

@interface NSIndexPath
-(IBAction) to_s;

@end

@interface NSLayoutConstraint
-(IBAction) to_s;

@end

@interface NSNotification
-(IBAction) to_s;
-(IBAction) inspect;

@end

@interface NSSet
-(IBAction) to_s;

@end

@interface NSURL
-(IBAction) to_s;
-(IBAction) inspect;

@end

@interface UIColor
-(IBAction) to_s;
-(IBAction) inspect;

@end

@interface UIEvent
-(IBAction) to_s;

@end

@interface UILabel
-(IBAction) to_s:(id) options;

@end

@interface UITextField
-(IBAction) to_s:(id) options;

@end

@interface UITouch
-(IBAction) to_s;

@end

@interface UIView
-(IBAction) to_s:(id) options;

@end

@interface UIViewController
-(IBAction) to_s;

@end

@interface CLLocationCoordinate2D
-(IBAction) distance_to:(id) cl_location_2d;

@end

@interface UIControl
-(IBAction) sugarcube_callbacks;
-(IBAction) call;

@end

@interface UITextView
-(IBAction) sugarcube_callbacks;

@end

@interface UIActionSheet
-(IBAction) dummy;

@end

@interface UIActivityIndicatorView
-(IBAction) large;
-(IBAction) white;
-(IBAction) gray;

@end

@interface UIAlertView
-(IBAction) dummy;

@end

@interface UIBarButtonItem
-(IBAction) sugarcube_handle_action:(id) sender;

@end

@interface UIButton
-(IBAction) custom;
-(IBAction) rounded;
-(IBAction) rounded_rect;
-(IBAction) detail;
-(IBAction) detail_disclosure;
-(IBAction) info;
-(IBAction) info_light;
-(IBAction) info_dark;
-(IBAction) contact;
-(IBAction) contact_add;

@end

@interface UISegmentedControl
-(IBAction) plain:(id) items;
-(IBAction) bordered:(id) items;
-(IBAction) bar:(id) items;
-(IBAction) bezeled:(id) items;

@end

@interface NSString
-(IBAction) document;
-(IBAction) cache;
-(IBAction) app_support;
-(IBAction) resource;
-(IBAction) resource_url;
-(IBAction) info_plist;

@end

@interface NSArray
-(IBAction) nsindexpath;
-(IBAction) nsindexset;
-(IBAction) nsset;

@end

@interface NSIndexPath
-(IBAction) to_a;

@end

@interface NSIndexSet
-(IBAction) to_a;

@end

@interface NSString
-(IBAction) nsurl;
-(IBAction) fileurl;
-(IBAction) escape_url;
-(IBAction) unescape_url;

@end

@interface NSURL
-(IBAction) open;
-(IBAction) nsurlrequest;
-(IBAction) nsmutableurlrequest;

@end

@interface UIView
-(IBAction) off_gestures;
-(IBAction) sugarcube_handle_gesture:(id) recognizer;

@end

@interface CIColor
-(IBAction) cicolor;

@end

@interface CIFilter
-(IBAction) uiimage;
-(IBAction) ciimage;
-(IBAction) color_invert;
-(IBAction) mask_to_alpha;
-(IBAction) maximum_component;
-(IBAction) minimum_component;
-(IBAction) random_generator;

@end

@interface CIImage
-(IBAction) ciimage;
-(IBAction) apply_filter:(id) filter;

@end

@interface UIColor
-(IBAction) cicolor;

@end

@interface UIImage
-(IBAction) crop:(id) rect;
-(IBAction) in_rect:(id) rect;
-(IBAction) scale_to_fill:(id) new_size;
-(IBAction) scale_within:(id) new_size;
-(IBAction) scale_to:(id) new_size;
-(IBAction) rounded:(id) corner_radius;
-(IBAction) apply_filter:(id) filter;
-(IBAction) cgimage;
-(IBAction) ciimage;
-(IBAction) darken:(id) options;
-(IBAction) rotate:(id) angle_or_direction;
-(IBAction) tileable:(id) insets;
-(IBAction) stretchable:(id) insets;
-(IBAction) alignment_rect:(id) insets;
-(IBAction) masked:(id) mask_image;
-(IBAction) color_at:(id) point;
-(IBAction) at_scale:(id) scale;

@end

@interface IndexPath
-(IBAction) initialize:(id) values;

@end

@interface NSError
-(IBAction) localized;

@end

@interface NSCoder
-(IBAction) bool:(id) key;
-(IBAction) double:(id) key;
-(IBAction) float:(id) key;
-(IBAction) int:(id) key;
-(IBAction) point:(id) key;
-(IBAction) rect:(id) key;
-(IBAction) size:(id) key;

@end

@interface NSData
-(IBAction) nsstring:(id) encoding;
-(IBAction) uiimage:(id) scale;

@end

@interface NSString
-(IBAction) nsdata:(id) encoding;

@end

@interface NSURL
-(IBAction) nsdata;

@end

@interface Numeric
-(IBAction) milliseconds;
-(IBAction) in_milliseconds;
-(IBAction) seconds;
-(IBAction) in_seconds;
-(IBAction) minutes;
-(IBAction) in_minutes;
-(IBAction) hours;
-(IBAction) in_hours;
-(IBAction) days;
-(IBAction) in_days;
-(IBAction) weeks;
-(IBAction) in_weeks;
-(IBAction) months;
-(IBAction) in_months;
-(IBAction) years;
-(IBAction) in_years;

@end

@interface String
-(IBAction) to_date;
-(IBAction) to_timezone;
-(IBAction) to_duration;

@end

@interface Fixnum
-(IBAction) nstimezone;
-(IBAction) before:(id) date;
-(IBAction) ago;
-(IBAction) after:(id) date;
-(IBAction) hence;

@end

@interface NSDate
-(IBAction) string_with_format:(id) format;
-(IBAction) timezone;
-(IBAction) era;
-(IBAction) utc_offset;
-(IBAction) date_array;
-(IBAction) time_array;
-(IBAction) datetime_array;
-(IBAction) start_of_day;
-(IBAction) end_of_day;
-(IBAction) start_of_week:(id) start_day;
-(IBAction) end_of_week:(id) start_day;
-(IBAction) start_of_month;
-(IBAction) end_of_month;
-(IBAction) days_in_month;
-(IBAction) days_in_year;
-(IBAction) days_to_week_start:(id) start_day;
-(IBAction) local_week_start;
-(IBAction) week_day_index:(id) week_day;

@end

@interface NSString
-(IBAction) nstimezone;

@end

@interface NSUserDefaults
-(IBAction) remove:(id) key;

@end

@interface Object
-(IBAction) to_nsuserdefaults;

@end

@interface NilClass
-(IBAction) to_nsuserdefaults;

@end

@interface NSArray
-(IBAction) to_nsuserdefaults;

@end

@interface NSDictionary
-(IBAction) to_nsuserdefaults;

@end

@interface Fixnum
-(IBAction) nth;
-(IBAction) ordinalize;

@end

@interface NSString
-(IBAction) to_number;

@end

@interface Numeric
-(IBAction) percent;
-(IBAction) g;
-(IBAction) in_g;
-(IBAction) radians;
-(IBAction) in_radians;
-(IBAction) degrees;
-(IBAction) in_degrees;
-(IBAction) pi;
-(IBAction) meters;
-(IBAction) in_meters;
-(IBAction) kilometers;
-(IBAction) in_kilometers;
-(IBAction) miles;
-(IBAction) in_miles;
-(IBAction) feet;
-(IBAction) in_feet;
-(IBAction) bytes;
-(IBAction) kilobytes;
-(IBAction) megabytes;
-(IBAction) gigabytes;
-(IBAction) terabytes;
-(IBAction) petabytes;
-(IBAction) exabytes;
-(IBAction) in_bytes;
-(IBAction) in_kilobytes;
-(IBAction) in_megabytes;
-(IBAction) in_gigabytes;
-(IBAction) in_terabytes;
-(IBAction) in_petabytes;
-(IBAction) in_exabytes;
-(IBAction) string_with_style:(id) style;

@end

@interface NSArray
-(IBAction) to_pointer:(id) type;

@end

@interface NSAttributedString
-(IBAction) uilabel;

@end

@interface NSString
-(IBAction) uiimage;
-(IBAction) uifont:(id) size;
-(IBAction) uilabel:(id) font;
-(IBAction) uiimageview;

@end

@interface Symbol
-(IBAction) uifont:(id) size;
-(IBAction) uifontsize;

@end

@interface UIImage
-(IBAction) uiimageview;

@end

@interface UILabel
-(IBAction) fit_to_size:(id) max_size;

@end

@interface UIView
-(IBAction) first_responder;
-(IBAction) unshift:(id) view;
-(IBAction) controller;
-(IBAction) uiimage:(id) use_content_size;
-(IBAction) convert_bounds:(id) destination;
-(IBAction) convert_origin:(id) destination;

@end

@interface UIViewController
-(IBAction) push:(id) view_controller;
-(IBAction) pop;

@end

@interface UINavigationController
-(IBAction) push:(id) view_controller;
-(IBAction) pop:(id) to_view;

@end

@interface UITabBarController
-(IBAction) push:(id) view_controller;

@end

@interface UIWebView
-(IBAction) eval_js:(id) str;

@end

@interface Symbol
-(IBAction) ivar;
-(IBAction) setter;
-(IBAction) cvar;

@end

@interface NSString
-(IBAction) ivar;
-(IBAction) setter;
-(IBAction) cvar;

@end

@interface Base
-(IBAction) initialize:(id) params;
-(IBAction) to_hash;
-(IBAction) hash;
-(IBAction) isEqual:(id) other;
-(IBAction) encodeWithCoder:(id) encoder;
-(IBAction) initWithCoder:(id) decoder;
-(IBAction) copyWithZone:(id) zone;

@end

@interface FormController: UITableViewController
-(IBAction) initWithForm:(id) form;
-(IBAction) form;
-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) push_subform:(id) form;
-(IBAction) pop_subform;

@end

@interface FormableController: Formotion
-(IBAction) initWithModel:(id) model;

@end

@interface InvalidClassError: StandardError
@end

@interface InvalidSectionError: StandardError
@end

@interface NoRowTypeError: StandardError
-(IBAction) assert_nil_or_boolean:(id) obj;

@end

@interface Conditions
-(IBAction) assert_nil_or_boolean:(id) obj;

@end

@interface Form: Formotion
-(IBAction) initialize:(id) params;
-(IBAction) initialize_persist;
-(IBAction) create_section:(id) hash;
-(IBAction) sections;
-(IBAction) row_for_index_path:(id) index_path;
-(IBAction) row:(id) key;
-(IBAction) submit;
-(IBAction) to_hash;
-(IBAction) render;
-(IBAction) sub_render;
-(IBAction) values;
-(IBAction) init_observer_for_save;
-(IBAction) open;
-(IBAction) save;
-(IBAction) reset;
-(IBAction) persist_key;
-(IBAction) original_persist_key;
-(IBAction) load_state;
-(IBAction) recursive_delete_nil:(id) h;

@end

@interface Form: Formotion
-(IBAction) active_row;
-(IBAction) controller;
-(IBAction) table;
-(IBAction) reload_data;
-(IBAction) numberOfSectionsInTableView:(id) tableView;

@end

@interface Object
-(IBAction) to_archived_data;

@end

@interface NSData
-(IBAction) unarchive;

@end

@interface UIActionSheet
-(IBAction) addButtonWithTitle:(id) title;

@end

@interface UITextField
-(IBAction) add_delegate_method;

@end

@interface UITextField_Delegate
-(IBAction) textFieldShouldBeginEditing:(id) theTextField;
-(IBAction) textFieldDidBeginEditing:(id) theTextField;
-(IBAction) textFieldShouldEndEditing:(id) theTextField;
-(IBAction) textFieldDidEndEditing:(id) theTextField;
-(IBAction) on_change:(id) theTextField;
-(IBAction) textFieldShouldClear:(id) theTextField;
-(IBAction) textFieldShouldReturn:(id) theTextField;

@end

@interface UITextView
-(IBAction) add_delegate_method;
-(IBAction) textViewShouldBeginEditing:(id) theTextView;

@end

@interface UITextView_Delegate
-(IBAction) textViewShouldBeginEditing:(id) theTextView;
-(IBAction) textViewDidBeginEditing:(id) theTextView;
-(IBAction) textViewShouldEndEditing:(id) theTextView;
-(IBAction) textViewDidEndEditing:(id) theTextView;
-(IBAction) textViewDidChange:(id) theTextView;

@end

@interface UITextView
-(IBAction) initWithCoder:(id) decoder;
-(IBAction) initWithFrame:(id) frame;
-(IBAction) setup;
-(IBAction) dealloc;
-(IBAction) drawRect:(id) rect;
-(IBAction) setText:(id) text;
-(IBAction) placeholder;
-(IBAction) placeholder_rect;
-(IBAction) placeholder_color;
-(IBAction) updateShouldDrawPlaceholder;

@end

@interface Row: Formotion
-(IBAction) initialize:(id) params;
-(IBAction) after_create;
-(IBAction) value_for_save_hash;
-(IBAction) index_path;
-(IBAction) form;
-(IBAction) reuse_identifier;
-(IBAction) next_row;
-(IBAction) previous_row;
-(IBAction) items;
-(IBAction) type;
-(IBAction) range;
-(IBAction) return_key;
-(IBAction) auto_correction;
-(IBAction) auto_capitalization;
-(IBAction) clear_button;
-(IBAction) text_alignment;
-(IBAction) selection_style;
-(IBAction) editable;
-(IBAction) make_cell;
-(IBAction) update_cell:(id) cell;
-(IBAction) to_hash;
-(IBAction) subform;
-(IBAction) to_form;
-(IBAction) load_constants_hack;

@end

@interface BackRow: ButtonRow
@end

@interface Base
-(IBAction) tableView;
-(IBAction) initialize:(id) row;
-(IBAction) cell_style;
-(IBAction) cellEditingStyle;
-(IBAction) build_cell:(id) cell;
-(IBAction) after_build:(id) cell;
-(IBAction) update_cell:(id) cell;
-(IBAction) delete_row;
-(IBAction) after_delete;

@end

@interface ButtonRow: Base
-(IBAction) build_cell:(id) cell;
-(IBAction) layoutSubviews;

@end

@interface CheckRow: Base
-(IBAction) update_cell_value:(id) cell;
-(IBAction) build_cell:(id) cell;

@end

@interface CurrencyRow: NumberRow
-(IBAction) on_change:(id) text_field;
-(IBAction) row_value;
-(IBAction) value_for_save_hash;
-(IBAction) number_formatter;
-(IBAction) currency_scale;

@end

@interface DateRow: StringRow
-(IBAction) on_change:(id) text_field;
-(IBAction) update;
-(IBAction) date_value;
-(IBAction) formatter;
-(IBAction) after_build:(id) cell;
-(IBAction) picker;
-(IBAction) picker_mode;
-(IBAction) formatted_value;
-(IBAction) update_text_field:(id) new_value;

@end

@interface EditRow: ButtonRow
@end

@interface EmailRow: StringRow
-(IBAction) keyboardType;

@end

@interface ImageRow: Base
-(IBAction) build_cell:(id) cell;
-(IBAction) layoutSubviews;
-(IBAction) add_plus_accessory:(id) cell;

@end

@interface MapRowData
-(IBAction) title;
-(IBAction) subtitle;
-(IBAction) coordinate;

@end

@interface MapRow: Base
-(IBAction) set_pin;
-(IBAction) annotations;
-(IBAction) build_cell:(id) cell;
-(IBAction) layoutSubviews;

@end

@interface NumberRow: StringRow
-(IBAction) keyboardType;

@end

@interface ObjectRow: StringRow
-(IBAction) build_cell:(id) cell;
-(IBAction) layoutSubviews;
-(IBAction) update_text_field:(id) new_value;
-(IBAction) row_value;

@end

@interface OptionsRow: Base
-(IBAction) build_cell:(id) cell;

@end

@interface PagedImageRow: Base
-(IBAction) build_cell:(id) cell;
-(IBAction) layoutSubviews;
-(IBAction) add_plus_accessory:(id) cell;
-(IBAction) loadVisiblePages;
-(IBAction) get_active_page;
-(IBAction) pages_single_tap;
-(IBAction) clearPages;
-(IBAction) resizePages;

@end

@interface PhoneRow: StringRow
-(IBAction) keyboardType;

@end

@interface PickerRow: StringRow
-(IBAction) after_build:(id) cell;
-(IBAction) picker;
-(IBAction) numberOfComponentsInPickerView:(id) pickerView;
-(IBAction) on_change:(id) text_field;
-(IBAction) update_text_field:(id) new_value;
-(IBAction) select_picker_value:(id) new_value;
-(IBAction) row_value;

@end

@interface SliderRow: Base
-(IBAction) build_cell:(id) cell;
-(IBAction) layoutSubviews;

@end

@interface StaticRow: StringRow
-(IBAction) after_build:(id) cell;

@end

@interface StringRow: Base
-(IBAction) keyboardType;
-(IBAction) build_cell:(id) cell;
-(IBAction) layoutSubviews;
-(IBAction) setText:(id) text;
-(IBAction) row_value;
-(IBAction) add_callbacks:(id) field;
-(IBAction) on_change:(id) text_field;
-(IBAction) update_text_field:(id) new_value;
-(IBAction) input_accessory_view:(id) input_accessory;
-(IBAction) done_editing;

@end

@interface SubformRow: Base
-(IBAction) build_cell:(id) cell;
-(IBAction) layoutSubviews;
-(IBAction) update_cell:(id) cell;
-(IBAction) display_key_label;

@end

@interface SubmitRow: ButtonRow
@end

@interface SwitchRow: Base
-(IBAction) build_cell:(id) cell;

@end

@interface TagsRow: Base
-(IBAction) build_cell:(id) cell;
-(IBAction) layoutSubviews;
-(IBAction) add_plus_accessory:(id) cell;
-(IBAction) image_for_state:(id) state;
-(IBAction) attrib_for_state:(id) state;
-(IBAction) add_tag:(id) text;
-(IBAction) button_click:(id) btn;

@end

@interface TemplateRow: Base
-(IBAction) cellEditingStyle;
-(IBAction) build_cell:(id) cell;
-(IBAction) build_new_row:(id) options;
-(IBAction) after_delete;
-(IBAction) move_row_in_list:(id) new_row;
-(IBAction) update_template_rows;

@end

@interface TextRow: Base
-(IBAction) build_cell:(id) cell;
-(IBAction) layoutSubviews;
-(IBAction) dismissKeyboard;

@end

@interface WebViewRow: Base
-(IBAction) set_page;
-(IBAction) stringByEvaluatingJavaScriptFromString:(id) script;
-(IBAction) loading;
-(IBAction) build_cell:(id) cell;
-(IBAction) layoutSubviews;
-(IBAction) webViewDidFinishLoad:(id) web_view;

@end

@interface Section: Formotion
-(IBAction) initialize:(id) params;
-(IBAction) generate_row:(id) hash;
-(IBAction) create_row:(id) hash;
-(IBAction) rows;
-(IBAction) index;
-(IBAction) next_section;
-(IBAction) previous_section;
-(IBAction) refresh_row_indexes;
-(IBAction) to_hash;

@end

@interface AppDelegate
-(IBAction) window;
-(IBAction) initAppearance;

@end

@interface ALViewController: UIViewController
-(IBAction) viewDidLoad;
-(IBAction) layout_subviews;
-(IBAction) layout_subviews2;
-(IBAction) supportedInterfaceOrientations;
-(IBAction) preferredInterfaceOrientationForPresentation;

@end

@interface AppuntiController: UITableViewController
-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) viewDidAppear:(id) animated;
-(IBAction) viewDidDisappear:(id) animated;
-(IBAction) contentSizeCategoryChanged:(id) notification;
-(IBAction) reload;
-(IBAction) numberOfSectionsInTableView:(id) tableView;
-(IBAction) loadFromBackend;

@end

@interface AppuntoFormController: UITableViewController
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) changes:(id) sender;
-(IBAction) didSave:(id) sender;
-(IBAction) cancel:(id) sender;
-(IBAction) save:(id) sender;
-(IBAction) print_appunto;
-(IBAction) documentInteractionControllerViewControllerForPreview:(id) controller;
-(IBAction) numberOfSectionsInTableView:(id) tableView;

@end

@interface ClienteDetailController: UIViewController

@property IBOutlet id tableView;

-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) viewWillDisappear:(id) animated;
-(IBAction) contentSizeCategoryChanged:(id) notification;
-(IBAction) reload;
-(IBAction) appunti_da_fare;
-(IBAction) appunti_in_sospeso;
-(IBAction) appunti_completati;
-(IBAction) sorted_appunti;
-(IBAction) numberOfSectionsInTableView:(id) tableView;
-(IBAction) navigate:(id) sender;
-(IBAction) makeCall:(id) sender;
-(IBAction) sendEmail:(id) sender;
-(IBAction) goToSite:(id) sender;
-(IBAction) loadFromBackend;

@end

@interface ClienteFormController: Formotion
-(IBAction) init;
-(IBAction) initWithCliente:(id) cliente;
-(IBAction) viewDidLoad;
-(IBAction) submit;
-(IBAction) tipi_clienti_rows;

@end

@interface ClientiController: UITableViewController
-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) viewWillDisappear:(id) animated;
-(IBAction) contentSizeCategoryChanged:(id) notification;
-(IBAction) reload;
-(IBAction) changeMode:(id) sender;
-(IBAction) changeProvincia:(id) sender;
-(IBAction) scrollToClienteAndPush:(id) cliente;
-(IBAction) buttonTappedAction:(id) sender;
-(IBAction) fetchControllerForTableView:(id) tableView;
-(IBAction) numberOfSectionsInTableView:(id) tableView;
-(IBAction) loadFromBackend;

@end

@interface DetailController: UIViewController

@property IBOutlet id labelTitolo;
@property IBOutlet id labelSottotitolo;
@property IBOutlet id headerView;

-(IBAction) viewDidLoad;
-(IBAction) scrollToTop;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) viewWillDisappear:(id) animated;
-(IBAction) changeTitolo:(id) notification;
-(IBAction) loadData;

@end

@interface DynamicController: UIViewController

@property IBOutlet id fakeTableView;

-(IBAction) viewDidLoad;
-(IBAction) handleTap:(id) gesture;
-(IBAction) handlePan:(id) gesture;
-(IBAction) itemBehaviourForView:(id) view;
-(IBAction) tryDockView:(id) view;
-(IBAction) fetchControllerForTableView:(id) tableView;
-(IBAction) searchBarShouldBeginEditing:(id) searchBar;
-(IBAction) searchBarShouldEndEditing:(id) searchBar;
-(IBAction) searchDisplayControllerWillBeginSearch:(id) controller;
-(IBAction) searchDisplayControllerDidEndSearch:(id) controller;
-(IBAction) numberOfSectionsInTableView:(id) tableView;
-(IBAction) buttonTappedAction:(id) sender;

@end

@interface DynamicNewController: UIViewController

@property IBOutlet id fakeTableView;

-(IBAction) viewDidLoad;
-(IBAction) handleTap:(id) gesture;
-(IBAction) handlePan:(id) gesture;
-(IBAction) itemBehaviourForView:(id) view;
-(IBAction) tryDockView:(id) view;
-(IBAction) moveDownViews:(id) view;
-(IBAction) fetchControllerForTableView:(id) tableView;
-(IBAction) searchBarShouldBeginEditing:(id) searchBar;
-(IBAction) searchBarShouldEndEditing:(id) searchBar;
-(IBAction) searchDisplayControllerWillBeginSearch:(id) controller;
-(IBAction) searchDisplayControllerDidEndSearch:(id) controller;
-(IBAction) numberOfSectionsInTableView:(id) tableView;
-(IBAction) buttonTappedAction:(id) sender;

@end

@interface EditListController: UITableViewController
-(IBAction) initWithItems:(id) items;
-(IBAction) viewDidLoad;
-(IBAction) cancel:(id) sender;

@end

@interface EditPrezzoViewController: UITableViewController

@property IBOutlet id editPrezzo;
@property IBOutlet id editSconto;

-(IBAction) viewWillAppear:(id) animated;
-(IBAction) prezzi;
-(IBAction) sconti;
-(IBAction) load_data;
-(IBAction) handleButtonDone;
-(IBAction) showDoneButton:(id) sender;
-(IBAction) done:(id) sender;
-(IBAction) close:(id) sender;

@end

@interface EditReminderController: UIViewController

@property IBOutlet id titleText;
@property IBOutlet id dateButton;
@property IBOutlet id tableView;

-(IBAction) init;
-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) viewWillDisappear:(id) animated;
-(IBAction) handleReminderCompletion;
-(IBAction) performEventOperations;
-(IBAction) performReminderOperations;
-(IBAction) dismiss;
-(IBAction) show_date_picker;
-(IBAction) pick_date;
-(IBAction) close_date_picker;
-(IBAction) numberOfSectionsInTableView:(id) tableView;
-(IBAction) setup_date_picker;

@end

@interface EditStatoViewController: UITableViewController
-(IBAction) close:(id) sender;

@end

@interface EditTextFieldController: UIViewController
-(IBAction) initWithType:(id) fieldType;
-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) text_label;
-(IBAction) text_field;
-(IBAction) handleTextCompletion;
-(IBAction) done:(id) sender;
-(IBAction) cancel:(id) sender;
-(IBAction) textFieldShouldReturn:(id) textField;
-(IBAction) textFieldDidBeginEditing:(id) textField;

@end

@interface EditTextViewController: UIViewController

@property IBOutlet id textView;
@property IBOutlet id textField;

-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) handleTextCompletion;
-(IBAction) done:(id) sender;
-(IBAction) cancel:(id) sender;
-(IBAction) textFieldShouldReturn:(id) textField;

@end

@interface LibriController: UIViewController

@property IBOutlet id tableView;

-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) viewWillDisappear:(id) animated;
-(IBAction) viewDidAppear:(id) animated;
-(IBAction) reload;
-(IBAction) close:(id) sender;
-(IBAction) fetchControllerForTableView:(id) tableView;
-(IBAction) numberOfSectionsInTableView:(id) tableView;
-(IBAction) loadFromBackend;

@end

@interface LibroAddController: UIViewController
-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) loadData;
-(IBAction) labelAuthors;
-(IBAction) labelTitle;
-(IBAction) labelPublisher;
-(IBAction) labelISBN;
-(IBAction) imageCover;
-(IBAction) buttonCreate;
-(IBAction) buttonEdit;
-(IBAction) buttonDismiss;
-(IBAction) bookCreate:(id) sender;
-(IBAction) bookEdit:(id) sender;
-(IBAction) dismiss;

@end

@interface LibroFormController: UITableViewController
-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) load_data:(id) libro;
-(IBAction) save:(id) sender;
-(IBAction) cancel:(id) sender;
-(IBAction) numberOfSectionsInTableView:(id) tableView;

@end

@interface LoginController: Formotion
-(IBAction) init;
-(IBAction) login;

@end

@interface MainController: UIViewController

@property IBOutlet id menuView;
@property IBOutlet id detailView;

-(IBAction) viewDidLoad;
-(IBAction) preferredStatusBarStyle;
-(IBAction) importa:(id) sender;
-(IBAction) login:(id) sender;
-(IBAction) esegui_importazione;

@end

@interface MenuController: UITableViewController
-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) viewWillDisappear:(id) animated;
-(IBAction) ricalcola;
-(IBAction) nel_baule_count;
-(IBAction) in_sospeso_count;
-(IBAction) da_fare_count;
-(IBAction) tutti_count;

@end

@interface RigaFormController: UITableViewController

@property IBOutlet id editQuantita;
@property IBOutlet id editPrezzo;

-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) load_riga;
-(IBAction) save:(id) sender;
-(IBAction) cancel:(id) sender;

@end

@interface ScanController: UIViewController
-(IBAction) initWithAppunto:(id) appunto;
-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) viewWillDisappear:(id) animated;
-(IBAction) applicationWillEnterForeground:(id) notification;
-(IBAction) applicationDidEnterBackground:(id) notification;
-(IBAction) displayBook:(id) notification;
-(IBAction) torchButtonAction:(id) sender;
-(IBAction) startRunning;
-(IBAction) stopRunning;
-(IBAction) setupCaptureSession;
-(IBAction) processMetadataObject:(id) code;
-(IBAction) previewView;
-(IBAction) rectOfInterestView;
-(IBAction) tableView;
-(IBAction) buttonDismiss;
-(IBAction) dismiss;
-(IBAction) numberOfSectionsInTableView:(id) tableView;

@end

@interface SearchClienteController: UIViewController

@property IBOutlet id fakeTableView;
@property IBOutlet id menuContainer;

-(IBAction) viewDidLoad;
-(IBAction) fetchControllerForTableView:(id) tableView;
-(IBAction) searchDisplayControllerWillBeginSearch:(id) controller;
-(IBAction) searchDisplayControllerDidEndSearch:(id) controller;
-(IBAction) numberOfSectionsInTableView:(id) tableView;
-(IBAction) buttonTappedAction:(id) sender;

@end

@interface CredentialStore
-(IBAction) clear_saved_credential_store;
-(IBAction) token;
-(IBAction) username;
-(IBAction) password;

@end

@interface DataImporterResult
-(IBAction) body;

@end

@interface DataImporter
-(IBAction) errorMessageForResponse:(id) operation;
-(IBAction) sync_appunti;

@end

@interface EKEventEditViewController
-(IBAction) saveEvent;
-(IBAction) removeEvent;

@end

@interface NSArray
-(IBAction) to_ip;
-(IBAction) mean;
-(IBAction) to_json;

@end

@interface NSEntityDescription
-(IBAction) wireRelationships;

@end

@interface NSIndexPath
-(IBAction) to_a;

@end

@interface NSManagedObject
-(IBAction) to_cells:(id) delegate;
-(IBAction) from_cells:(id) cells;

@end

@interface NSManagedObject
-(IBAction) refresh_backend;
-(IBAction) update;
-(IBAction) remove;
-(IBAction) persist;
-(IBAction) managedObjectClass;

@end

@interface NSManagedObject
-(IBAction) from_json:(id) json;
-(IBAction) to_json;
-(IBAction) to_json_raw;
-(IBAction) to_json_attr:(id) attr;
-(IBAction) to_json_rel:(id) rel;

@end

@interface Time
-(IBAction) year;
-(IBAction) days_to:(id) other;
-(IBAction) days_add:(id) days;

@end

@interface UIBarButtonItemPlain: UIBarButtonItem
@end

@interface UIBarButtonItemEdit: UIBarButtonItem
@end

@interface UIBarButtonItemAdd: UIBarButtonItem
@end

@interface UIBarButtonItemDone: UIBarButtonItem
@end

@interface UIBarButtonItemCancel: UIBarButtonItem
@end

@interface UINavigationControllerDoneCancel: UINavigationController
@end

@interface UITableView
-(IBAction) updates;

@end

@interface UITableViewCell
-(IBAction) title;
-(IBAction) subtitle;
-(IBAction) tick:(id) aBoolean;
-(IBAction) disclose:(id) aBoolean;
-(IBAction) clear;

@end

@interface UITableViewController
-(IBAction) viewDidLoad;
-(IBAction) viewDidUnload;
-(IBAction) keyboardDidShow:(id) notification;
-(IBAction) keyboardWillHide:(id) notification;

@end

@interface UITableViewControllerForNSManagedObject: UITableViewController
-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) updateObject;
-(IBAction) shouldAutorotateToInterfaceOrientation:(id) interfaceOrientation;
-(IBAction) sections;
-(IBAction) numberOfSectionsInTableView:(id) tableView;
-(IBAction) textFieldShouldReturn:(id) textField;

@end

@interface UITableViewTextFieldCell: UITableViewCell
-(IBAction) textField;
-(IBAction) value;
-(IBAction) clear;
-(IBAction) layoutSubviews;

@end

@interface UITableViewTextViewCell: UITableViewCell
-(IBAction) textView;
-(IBAction) value;
-(IBAction) clear;
-(IBAction) layoutSubviews;

@end

@interface UIView
-(IBAction) firstResponder;
-(IBAction) viewController;

@end

@interface MappingProvider
-(IBAction) libro_mapping;
-(IBAction) request_libro_mapping;
-(IBAction) cliente_mapping;
-(IBAction) request_cliente_mapping;
-(IBAction) appunto_mapping;
-(IBAction) request_appunto_mapping;
-(IBAction) request_riga_mapping;
-(IBAction) riga_mapping;
-(IBAction) classe_mapping;
-(IBAction) request_classe_mapping;
-(IBAction) adozione_mapping;
-(IBAction) request_adozione_mapping;

@end

@interface Adozione: NSManagedObject
-(IBAction) save_to_backend;

@end

@interface Appunto: NSManagedObject
-(IBAction) data;
-(IBAction) note_e_righe;
-(IBAction) calcola_importo;
-(IBAction) calcola_copie;
-(IBAction) remove;

@end

@interface Classe: NSManagedObject
-(IBAction) giornoSection;
-(IBAction) updated_at;
-(IBAction) save_to_backend;
-(IBAction) giorno_modifica;

@end

@interface Cliente: NSManagedObject
-(IBAction) provincia_e_comune;
-(IBAction) save_to_backend;
-(IBAction) whichGroup;
-(IBAction) citta;
-(IBAction) title;
-(IBAction) coordinate;
-(IBAction) mapItem;
-(IBAction) sum_copie;

@end

@interface Coordinates
-(IBAction) initialize:(id) attrs;
-(IBAction) to_cl;

@end

@interface Docente
-(IBAction) initialize:(id) attributes;

@end

@interface Libro: NSManagedObject
@end

@interface Riga: NSManagedObject
@end

@interface SecureMessage
-(IBAction) init;
-(IBAction) errorMessageForResponse:(id) operation;

@end

@interface Store
-(IBAction) set_token_header;
-(IBAction) token_changed:(id) notification;
-(IBAction) client;
-(IBAction) setupReachability;
-(IBAction) context;
-(IBAction) persistent_context;
-(IBAction) store;
-(IBAction) backend;
-(IBAction) save;
-(IBAction) persist;
-(IBAction) clear;
-(IBAction) stats;
-(IBAction) initialize;

@end

@interface UserAuthenticator
-(IBAction) retryOperationForOperation:(id) operation;
-(IBAction) errorMessageForResponse:(id) operation;

@end

@interface AppuntoCell: UITableViewCell

@property IBOutlet id labelDestinatario;
@property IBOutlet id labelNote;
@property IBOutlet id labelTotali;
@property IBOutlet id imageStatus;

@end

@interface AppuntoCellAuto: UITableViewCell
-(IBAction) get_height:(id) appunto;
-(IBAction) updateFonts;
-(IBAction) updateConstraints;

@end

@interface ClienteCell: UITableViewCell

@property IBOutlet id clienteLabel;
@property IBOutlet id cittaLabel;
@property IBOutlet id colorButton;

@end

@interface LibroCell: UITableViewCell

@property IBOutlet id imageCopertina;
@property IBOutlet id labelTitolo;
@property IBOutlet id labelPrezzoCopertina;

@end

@interface RigaCell: UITableViewCell
-(IBAction) load_data:(id) riga;
-(IBAction) addLabelsToSubview;
-(IBAction) newLabelTitolo;
-(IBAction) newLabelPrezzo;
-(IBAction) newLabelSconto;
-(IBAction) newLabelQuantita;
-(IBAction) newImageCopertina;

@end

@interface RigaCellIb: UITableViewCell

@property IBOutlet id labelTitolo;
@property IBOutlet id labelPrezzo;
@property IBOutlet id labelSconto;
@property IBOutlet id labelQuantita;
@property IBOutlet id imageCopertina;

-(IBAction) load_data:(id) riga;

@end

@interface TotaliCellIb: UITableViewCell

@property IBOutlet id labelImporto;
@property IBOutlet id labelCopie;

@end

@interface CircleButton: UIButton
-(IBAction) setColor:(id) color;
-(IBAction) nel_baule;
-(IBAction) drawRect:(id) rect;

@end

@interface HeaderCliente: UITableViewHeaderFooterView
-(IBAction) initWithReuseIdentifier:(id) reuseIdentifier;
-(IBAction) titolo;
-(IBAction) quantita;
-(IBAction) toggleBaule:(id) sender;
-(IBAction) toggleBauleWithUserAction:(id) userAction;

@end

