using ramnet.Utils: stack
using ramnet.Mappers: RandomMapper
using ramnet.Models: train!, predict
using ramnet.Models: Discriminator, BleachingDiscriminator

@testset "Discriminator" begin
    all_active = ones(Bool, 9)
    one_off    = Bool[0, ones(Bool, 8)...]

    d = Discriminator(length(all_active), 3)

    train!(d, all_active)

    @test predict(d, all_active) == 3
    @test predict(d, one_off) == 2

    inputs = stack(all_active, one_off)
    @test predict(d, inputs) == [3, 2]

    # Discriminator with externally-instantiated mapper
    mapper   = RandomMapper(length(all_active), 3)
    d_mapper = Discriminator(mapper)
    train!(d_mapper, all_active)
    @test predict(d_mapper, all_active) == 3

    # One-shot instantiation and training
    duplicated_input = stack(all_active, all_active)
    one_shot_d_1 = Discriminator(all_active, mapper)
    one_shot_d_2 = Discriminator(all_active, 3)
    one_shot_d_3 = Discriminator(duplicated_input, 3)

    @test predict(one_shot_d_1, all_active) == 3
    @test predict(one_shot_d_2, all_active) == 3
    @test predict(one_shot_d_3, all_active) == 3

    # Discriminators with bleaching
    b_d = BleachingDiscriminator(length(all_active), 3)

    train!(b_d, all_active)

    @test predict(b_d, all_active) == 3
    @test predict(b_d, one_off) == 2

    @test predict(b_d, all_active; b=1) == 0
    @test predict(b_d, one_off; b=1) == 0

    train!(b_d, one_off)

    @test predict(b_d, one_off) == 3
    @test predict(b_d, all_active; b=1) == 2
    @test predict(b_d, one_off; b=1) == 2
end
