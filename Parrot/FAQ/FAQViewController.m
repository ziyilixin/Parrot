//
//  FAQViewController.m
//  Parrot
//
//  Created by AI Assistant on 2025/09/10.
//

#import "FAQViewController.h"
#import "Masonry.h"
#import "ParrotColor.h"

@interface FAQViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *faqData;

@end

@implementation FAQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadFAQData];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Parrot Care Guide";
    
    // Setup navigation bar
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.navigationController.navigationBar.largeTitleTextAttributes = @{
        NSForegroundColorAttributeName: ParrotMainColor
    };
    
    // Setup table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // Register cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"FAQCell"];
}

- (void)loadFAQData {
    self.faqData = @[
        @{
            @"title": @"Parrot Classification",
            @"icon": @"bird",
            @"items": @[
                @{@"question": @"What are the main types of parrots?", @"answer": @"Parrots are divided into three main families: Psittacidae (true parrots), Cacatuidae (cockatoos), and Strigopidae (New Zealand parrots). Each family has unique characteristics and care requirements."},
                @{@"question": @"What's the difference between small and large parrots?", @"answer": @"Small parrots (like budgies and cockatiels) are generally easier to care for, require less space, and have shorter lifespans. Large parrots (like macaws and cockatoos) need more space, specialized care, and can live 50+ years."},
                @{@"question": @"Which parrot species are best for beginners?", @"answer": @"Budgies, cockatiels, and lovebirds are excellent choices for beginners due to their smaller size, easier care requirements, and generally friendly temperaments."}
            ]
        },
        @{
            @"title": @"Natural Habits & Behavior",
            @"icon": @"leaf",
            @"items": @[
                @{@"question": @"How much sleep do parrots need?", @"answer": @"Parrots need 10-12 hours of uninterrupted sleep per night. They should have a quiet, dark environment for sleeping to maintain their natural circadian rhythms."},
                @{@"question": @"Why do parrots scream?", @"answer": @"Parrots scream for various reasons: communication, attention-seeking, boredom, fear, or as a natural behavior. Understanding the cause helps in addressing the issue appropriately."},
                @{@"question": @"Do parrots need social interaction?", @"answer": @"Yes, parrots are highly social animals. They need daily interaction with their human family and benefit from mental stimulation through toys, puzzles, and training activities."}
            ]
        },
        @{
            @"title": @"Physical Structure & Lifecycle",
            @"icon": @"heart",
            @"items": @[
                @{@"question": @"How long do parrots live?", @"answer": @"Lifespan varies by species: small parrots (budgies) 5-10 years, medium parrots (cockatiels) 15-20 years, large parrots (macaws) 50-80 years. Proper care significantly impacts longevity."},
                @{@"question": @"What are the signs of a healthy parrot?", @"answer": @"Healthy parrots have bright, clear eyes, smooth feathers, active behavior, good appetite, and regular droppings. Any changes in these signs may indicate health issues."},
                @{@"question": @"How do parrots molt?", @"answer": @"Parrots molt 1-2 times per year, replacing old feathers with new ones. This process can take several weeks and may cause temporary changes in behavior and appearance."}
            ]
        },
        @{
            @"title": @"Cage Design & Setup",
            @"icon": @"house",
            @"items": @[
                @{@"question": @"What size cage does my parrot need?", @"answer": @"The cage should be large enough for your parrot to fully extend its wings and move around comfortably. As a rule, the cage should be at least 1.5 times the bird's wingspan in width."},
                @{@"question": @"What should I put in my parrot's cage?", @"answer": @"Essential items include perches of varying sizes, food and water dishes, toys for mental stimulation, and a comfortable sleeping area. Avoid overcrowding the cage."},
                @{@"question": @"Where should I place the cage?", @"answer": @"Place the cage in a well-lit area away from drafts, direct sunlight, and kitchen fumes. It should be at eye level or slightly higher, allowing the parrot to feel secure."}
            ]
        },
        @{
            @"title": @"Environmental Control",
            @"icon": @"thermometer",
            @"items": @[
                @{@"question": @"What temperature is ideal for parrots?", @"answer": @"Most parrots thrive in temperatures between 65-80°F (18-27°C). Avoid sudden temperature changes and drafts, which can cause health problems."},
                @{@"question": @"What humidity level do parrots need?", @"answer": @"Parrots need 40-60% humidity. Too low humidity can cause dry skin and respiratory issues, while too high can promote bacterial growth."},
                @{@"question": @"Do parrots need UV lighting?", @"answer": @"Yes, parrots benefit from natural sunlight or full-spectrum UV lighting for 2-4 hours daily. This helps with vitamin D synthesis and overall health."}
            ]
        },
        @{
            @"title": @"Scientific Feeding",
            @"icon": @"fork.knife",
            @"items": @[
                @{@"question": @"What should I feed my parrot?", @"answer": @"A balanced diet includes high-quality pellets (60-70%), fresh vegetables and fruits (20-30%), and occasional seeds or nuts (10%). Avoid avocado, chocolate, and caffeine."},
                @{@"question": @"How often should I feed my parrot?", @"answer": @"Provide fresh food twice daily and always have clean water available. Remove uneaten fresh food after 2-3 hours to prevent spoilage."},
                @{@"question": @"Can parrots eat human food?", @"answer": @"Some human foods are safe in moderation: cooked rice, pasta, vegetables, and fruits. Always research before offering new foods and avoid processed, salty, or sugary foods."}
            ]
        },
        @{
            @"title": @"Daily Care & Grooming",
            @"icon": @"scissors",
            @"items": @[
                @{@"question": @"How do I trim my parrot's wings?", @"answer": @"Wing trimming should be done by an experienced person or veterinarian. Only trim the primary flight feathers, leaving 2-3 outer feathers for balance and safety."},
                @{@"question": @"How do I trim my parrot's beak?", @"answer": @"Beak trimming is usually not necessary if your parrot has proper perches and toys. If needed, it should be done by a veterinarian to avoid injury."},
                @{@"question": @"How often should I clean the cage?", @"answer": @"Clean food and water dishes daily, spot-clean droppings daily, and do a thorough cage cleaning weekly. This prevents bacterial growth and maintains a healthy environment."}
            ]
        },
        @{
            @"title": @"Special Periods Management",
            @"icon": @"calendar",
            @"items": @[
                @{@"question": @"How do I care for a breeding parrot?", @"answer": @"Breeding parrots need extra nutrition, privacy, and nesting materials. Monitor their health closely and be prepared for potential complications during the breeding process."},
                @{@"question": @"How do I care for baby parrots?", @"answer": @"Baby parrots need frequent feeding (every 2-4 hours), proper temperature control, and gentle handling. Hand-feeding requires special knowledge and should be learned from experienced breeders."},
                @{@"question": @"What are the signs of breeding behavior?", @"answer": @"Signs include increased territorial behavior, nest building, regurgitation, and changes in vocalization. Provide appropriate nesting materials and monitor for any health issues."}
            ]
        },
        @{
            @"title": @"Emotions & Behavior Signals",
            @"icon": @"brain",
            @"items": @[
                @{@"question": @"How can I tell if my parrot is happy?", @"answer": @"Happy parrots are active, vocal, have bright eyes, smooth feathers, and show interest in their environment. They may also engage in play and social interaction."},
                @{@"question": @"What does it mean when my parrot fluffs up?", @"answer": @"Fluffing up can indicate relaxation, sleepiness, or illness. If accompanied by other symptoms like lethargy or loss of appetite, consult a veterinarian."},
                @{@"question": @"Why does my parrot bite?", @"answer": @"Biting can be due to fear, territorial behavior, hormonal changes, or lack of proper socialization. Understanding the cause helps in addressing the behavior appropriately."}
            ]
        },
        @{
            @"title": @"Health Status & Disease Prevention",
            @"icon": @"cross.case",
            @"items": @[
                @{@"question": @"What are common parrot diseases?", @"answer": @"Common diseases include psittacosis, aspergillosis, feather plucking, and nutritional deficiencies. Regular veterinary check-ups and proper care help prevent many health issues."},
                @{@"question": @"How often should I take my parrot to the vet?", @"answer": @"Healthy adult parrots should have annual check-ups. Young birds, breeding birds, or birds showing signs of illness may need more frequent visits."},
                @{@"question": @"What are emergency signs in parrots?", @"answer": @"Emergency signs include difficulty breathing, bleeding, inability to perch, loss of consciousness, or severe lethargy. Seek immediate veterinary care for these symptoms."}
            ]
        },
        @{
            @"title": @"Breeding & Rearing",
            @"icon": @"heart.fill",
            @"items": @[
                @{@"question": @"How do I choose breeding pairs?", @"answer": @"Choose healthy, unrelated birds of appropriate age. Both birds should be in good physical condition and show compatible temperaments."},
                @{@"question": @"What do I need for parrot breeding?", @"answer": @"You need a suitable breeding cage, nesting box, proper nutrition, and knowledge of incubation and hand-feeding techniques. Breeding requires significant commitment and expertise."},
                @{@"question": @"How long do parrot eggs take to hatch?", @"answer": @"Incubation periods vary by species: budgies 18 days, cockatiels 18-21 days, larger parrots 24-28 days. Proper temperature and humidity are crucial for successful hatching."}
            ]
        }
    ];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.faqData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionData = self.faqData[section];
    NSArray *items = sectionData[@"items"];
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FAQCell" forIndexPath:indexPath];
    
    NSDictionary *sectionData = self.faqData[indexPath.section];
    NSArray *items = sectionData[@"items"];
    NSDictionary *item = items[indexPath.row];
    
    // Configure cell
    cell.textLabel.text = item[@"question"];
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    cell.textLabel.textColor = ParrotTextDarkGray;
    cell.textLabel.numberOfLines = 0;
    
    cell.detailTextLabel.text = item[@"answer"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = ParrotTextGray;
    cell.detailTextLabel.numberOfLines = 0;
    
    // Style the cell
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Add rounded corners and shadow
    cell.layer.cornerRadius = 8;
    cell.layer.masksToBounds = NO;
    cell.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.layer.shadowOffset = CGSizeMake(0, 1);
    cell.layer.shadowOpacity = 0.1;
    cell.layer.shadowRadius = 2;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionData = self.faqData[section];
    return sectionData[@"title"];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.textLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        headerView.textLabel.textColor = ParrotMainColor;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *sectionData = self.faqData[indexPath.section];
    NSArray *items = sectionData[@"items"];
    NSDictionary *item = items[indexPath.row];
    
    // Show detailed answer in an alert
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:item[@"question"]
                                                                   message:item[@"answer"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
