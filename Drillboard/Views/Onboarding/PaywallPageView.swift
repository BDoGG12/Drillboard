import SwiftUI

struct PaywallPageView: View {
    let subscriptionManager: SubscriptionManager
    /// Called when the user dismisses the paywall without subscribing.
    let onNotNow: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 24)

            VStack(spacing: 14) {
                annualCard
                monthlyCard
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 20)

            restoreButton
                .padding(.bottom, 10)

            notNowButton
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Unlock Drillboard Pro")
                .font(.system(size: 32, weight: .bold))
            Text("Start your 7-day free trial")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Plan cards

    private var annualCard: some View {
        Button {
            subscriptionManager.purchaseAnnual()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Annual")
                        .font(.headline)
                    Spacer()
                    Text("MOST POPULAR")
                        .font(.caption2.weight(.bold))
                        .tracking(0.5)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.drillboardOrange, in: Capsule())
                        .foregroundStyle(.white)
                }

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("$59.99")
                        .font(.system(size: 30, weight: .bold))
                    Text("/year")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text("Billed annually · 7-day free trial · Just $5/month")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(Color.drillboardOrange.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.drillboardOrange, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Annual plan — $59.99 per year, most popular, 7-day free trial")
    }

    private var monthlyCard: some View {
        Button {
            subscriptionManager.purchaseMonthly()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Text("Monthly")
                    .font(.headline)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("$7.99")
                        .font(.system(size: 26, weight: .bold))
                    Text("/month")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text("Billed monthly · No trial")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Monthly plan — $7.99 per month, no trial")
    }

    // MARK: - Secondary actions

    private var restoreButton: some View {
        Button {
            subscriptionManager.restorePurchases()
        } label: {
            Text("Restore Purchases")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.drillboardOrange)
        }
        .buttonStyle(.plain)
    }

    private var notNowButton: some View {
        Button("Not now", action: onNotNow)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
    }
}
