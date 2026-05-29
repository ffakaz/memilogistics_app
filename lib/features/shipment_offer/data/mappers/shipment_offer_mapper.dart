// lib/features/shipment_offer/data/mappers/shipment_offer_mapper.dart

import 'package:memilogistics_app/features/carrier/data/mapper/carrier_company_mapper.dart';
import 'package:memilogistics_app/features/shipment_offer/data/models/shipment_offer_model.dart';
import 'package:memilogistics_app/features/shipment_offer/domain/entities/shipment_offer.dart';

/// Mapper between ShipmentOfferModel (data) and ShipmentOffer (domain)
class ShipmentOfferMapper {
  ShipmentOfferMapper._();

  /// Convert model to entity
  static ShipmentOffer toEntity(ShipmentOfferModel model) {
    return ShipmentOffer(
      id: model.id,
      createdAt: model.createdAt,
      price: model.price,
      shipmentId: model.shipmentId,
      shipmentTrackingNumber: model.shipmentTrackingNumber,
      carrierCompanyId: model.carrierCompanyId,
      carrierCompany: model.carrierCompany != null
          ? CarrierCompanyMapper.toEntity(model.carrierCompany!)
          : null,
    );
  }

  /// Convert entity to model
  static ShipmentOfferModel toModel(ShipmentOffer entity) {
    return ShipmentOfferModel(
      id: entity.id,
      createdAt: entity.createdAt,
      price: entity.price,
      shipmentId: entity.shipmentId,
      shipmentTrackingNumber: entity.shipmentTrackingNumber,
      carrierCompanyId: entity.carrierCompanyId,
      carrierCompany: entity.carrierCompany != null
          ? CarrierCompanyMapper.toModel(entity.carrierCompany!)
          : null,
    );
  }

  /// Convert list of models to entities
  static List<ShipmentOffer> toEntityList(List<ShipmentOfferModel> models) {
    return models.map(toEntity).toList();
  }

  /// Convert list of entities to models
  static List<ShipmentOfferModel> toModelList(List<ShipmentOffer> entities) {
    return entities.map(toModel).toList();
  }
}
