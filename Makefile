SAC2C := sac2c_d
# it is 'safe' to keep `-mt_bind` and `-cuda_arch` as these only have
# an effect when using MT or CUDA backends
SACFLAGS += -g -v1 -O3 -mt_bind simple -cuda_arch sm35
SAC2C_CALL = $(SAC2C) $(SACFLAGS)

# uppcase function
UC = $(shell echo '$1' | tr '[:lower:]' '[:upper:]')

.PHONY: all mnist emnist
.SECONDARY:

all: mnist emnist

mnist: cnn_mnist_seq cnn_mnist_mt cnn_mnist_cuda cnn_mnist_cuda_reg
emnist: cnn_emnist_seq cnn_emnist_mt cnn_emnist_cuda cnn_emnist_cuda_reg

# targets to build binaries
cnn_%_seq: zhang.sac host/seq/libmnistMod.so host/seq/libcnnMod.so
	$(SAC2C_CALL) -t seq -noEMRCI -D$(call UC,$*) -o $@ $<

cnn_%_mt: zhang.sac host/mt-pth/libmnistMod.so host/mt-pth/libcnnMod.so
	$(SAC2C_CALL) -minmtsize 50 -t mt_pth -noEMRCI -D$(call UC,$*) -o $@ $<

cnn_%_cuda: zhang.sac host/cuda/libmnistMod.so host/cuda/libcnnMod.so
	$(SAC2C_CALL) -t cuda -noEMRCI -D$(call UC,$*) -o $@ $<

cnn_%_cuda_reg: zhang.sac host/cuda-reg/libmnistMod.so host/cuda-reg/libcnnMod.so
	$(SAC2C_CALL) -t cuda_reg -noEMRCI -doCUAD -doCUADE -D$(call UC,$*) -o $@ $<

# targets to build libraries
host/seq/lib%Mod.so: %.sac
	$(SAC2C_CALL) -t seq -noEMRCI $<

host/mt-pth/lib%Mod.so: %.sac
	$(SAC2C_CALL) -minmtsize 50 -noEMRCI -t mt_pth $<

host/cuda/lib%Mod.so: %.sac
	$(SAC2C_CALL) -t cuda -noEMRCI $<

host/cuda-reg/lib%Mod.so: %.sac
	$(SAC2C_CALL) -t cuda_reg -noEMRCI $<

.PHONY: clean
clean:
	$(RM) -r host tree
	$(RM) cnn_*
