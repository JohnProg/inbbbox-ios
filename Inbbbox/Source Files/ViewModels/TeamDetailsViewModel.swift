//
//  TeamDetailsViewModel.swift
//  Inbbbox
//
//  Created by Peter Bruz on 04/05/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class TeamDetailsViewModel: ProfileViewModel {

    weak var delegate: BaseCollectionViewViewModelDelegate?

    var title: String {
        return team.name
    }

    var avatarURL: URL? {
        return team.avatarURL as URL?
    }

    var collectionIsEmpty: Bool {
        return teamMembers.isEmpty
    }

    var shouldShowFollowButton: Bool {
        return UserStorage.isUserSignedIn
    }

    var itemsCount: Int {
        return teamMembers.count
    }

    var teamMembers = [UserType]()
    var memberIndexedShots = [Int: [ShotType]]()

    fileprivate let connectionsRequester = APIConnectionsRequester()
    fileprivate let teamsProvider = APITeamsProvider()
    fileprivate let shotsProvider = ShotsProvider()

    fileprivate let team: TeamType

    init(team: TeamType) {
        self.team = team
    }

    func downloadInitialItems() {

        firstly {
            teamsProvider.provideMembersForTeam(team)
        }.then { teamMembers -> Void in
            if let teamMembers = teamMembers, teamMembers != self.teamMembers || teamMembers.count == 0 {
                self.teamMembers = teamMembers
                self.downloadShots(teamMembers)
                self.delegate?.viewModelDidLoadInitialItems()
            }
        }.catch { error in
            self.delegate?.viewModelDidFailToLoadInitialItems(error)
        }
    }

    func downloadItemsForNextPage() {

        firstly {
            teamsProvider.nextPage()
        }.then { teamMembers -> Void in
            if let teamMembers = teamMembers, teamMembers.count > 0 {
                let indexes = teamMembers.enumerated().map { index, _ in
                    return index + self.teamMembers.count
                }
                self.teamMembers.append(contentsOf: teamMembers)
                let indexPaths = indexes.map {
                    IndexPath(row: ($0), section: 0)
                }
                self.delegate?.viewModel(self, didLoadItemsAtIndexPaths: indexPaths)
                self.downloadShots(teamMembers)
            }
        }.catch { error in
            self.notifyDelegateAboutFailure(error)
        }
    }

    func isProfileFollowedByMe() -> Promise<Bool> {

        return Promise<Bool> { fulfill, reject in
            firstly {
                connectionsRequester.isTeamFollowedByMe(team)
            }.then(execute: fulfill).catch(execute: reject)
        }
    }

    func followProfile() -> Promise<Void> {

        return Promise<Void> { fulfill, reject in
            firstly {
                connectionsRequester.followTeam(team)
            }.then(execute: fulfill).catch(execute: reject)
        }
    }

    func unfollowProfile() -> Promise<Void> {

        return Promise<Void> { fulfill, reject in
            firstly {
                connectionsRequester.unfollowTeam(team)
            }.then(execute: fulfill).catch(execute: reject)
        }
    }

    func userCollectionViewCellViewData(_ indexPath: IndexPath) -> UserCollectionViewCellViewData {
        return UserCollectionViewCellViewData(user: teamMembers[indexPath.row],
                                                  shots: memberIndexedShots[indexPath.row])
    }
}

extension TeamDetailsViewModel {

    struct UserCollectionViewCellViewData {
        let name: String?
        let avatarURL: URL?
        let numberOfShots: String
        let shotsImagesURLs: [URL]?
        let firstShotImage: ShotImageType?

        init(user: UserType, shots: [ShotType]?) {
            self.name = user.name
            self.avatarURL = user.avatarURL as URL?
            self.numberOfShots = String.localizedStringWithFormat(NSLocalizedString("%d shots",
                comment: "How many shots in collection?"), user.shotsCount)
            if let shots = shots, shots.count > 0 {

                let allShotsImagesURLs = shots.map { $0.shotImage.teaserURL }

                switch allShotsImagesURLs.count {
                case 1:
                    shotsImagesURLs = [allShotsImagesURLs[0] as URL, allShotsImagesURLs[0] as URL,
                                       allShotsImagesURLs[0] as URL, allShotsImagesURLs[0] as URL]
                case 2:
                    shotsImagesURLs = [allShotsImagesURLs[0] as URL, allShotsImagesURLs[1] as URL,
                                       allShotsImagesURLs[1] as URL, allShotsImagesURLs[0] as URL]
                case 3:
                    shotsImagesURLs = [allShotsImagesURLs[0] as URL, allShotsImagesURLs[1] as URL,
                                       allShotsImagesURLs[2] as URL, allShotsImagesURLs[0] as URL]
                default:
                    shotsImagesURLs = [allShotsImagesURLs[0] as URL, allShotsImagesURLs[1] as URL,
                                       allShotsImagesURLs[2] as URL, allShotsImagesURLs[3] as URL]
                }
                firstShotImage = shots[0].shotImage
            } else {
                self.shotsImagesURLs = nil
                self.firstShotImage = nil
            }
        }
    }
}

private extension TeamDetailsViewModel {
    func downloadShots(_ teamMembers: [UserType]) {
        for member in teamMembers {
            firstly {
                shotsProvider.provideShotsForUser(member)
            }.then { shots -> Void in
                var indexOfMember: Int?
                for (index, item) in self.teamMembers.enumerated() {
                    if item.identifier == member.identifier {
                        indexOfMember = index
                        break
                    }
                }

                guard let index = indexOfMember else { return }

                if let shots = shots {
                    self.memberIndexedShots[index] = shots
                } else {
                    self.memberIndexedShots[index] = [ShotType]()
                }
                let indexPath = IndexPath(row: index, section: 0)
                self.delegate?.viewModel(self, didLoadShotsForItemAtIndexPath: indexPath)
            }.catch { error in
                self.notifyDelegateAboutFailure(error)
            }
        }
    }
}
