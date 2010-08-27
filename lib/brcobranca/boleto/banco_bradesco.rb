# Banco BRADESCO
class BancoBradesco < Brcobranca::Boleto::Base
  # Responsável por definir dados iniciais quando se cria uma nova intancia da classe BancoBradesco
  def initialize(campos={})
    padrao={:carteira => "06", :banco => "237"}
    campos = padrao.merge!(campos)
    super(campos)
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def nosso_numero_boleto
   "#{self.carteira}/#{self.numero_documento.to_s.rjust(11,'0')}-#{self.nosso_numero_dv}"
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def agencia_conta_boleto
   "#{self.agencia}-#{self.agencia_dv} / #{self.conta_corrente}-#{self.conta_corrente_dv}"
  end

  # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras
  #   As posições do campo livre ficam a critério de cada Banco arrecadador, sendo que o
  #   padrão do Bradesco é:
  #   Posição Tamanho Conteúdo
  #   20 a 23 4 Agência Cedente (Sem o digito verificador, completar com zeros a esquerda quando  necessário)
  #   24 a 25 2 Carteira
  #   26 a 36 11 Número do Nosso Número(Sem o digito verificador)
  #   37 a 43 7 Conta do Cedente (Sem o digito verificador, completar com zeros a esquerda quando necessário)
  #   44 a 44 1 Zero

  def monta_codigo_43_digitos
    banco = self.banco.to_s.rjust(3,'0')
    fator = self.data_vencimento.fator_vencimento
    valor_documento = self.valor_documento.limpa_valor_moeda.to_s.rjust(10,'0')
    agencia = self.agencia.to_s.rjust(4,'0')
    carteira = self.carteira.to_s.rjust(2,'0')
    numero_documento = self.numero_documento.to_s.rjust(11,'0')
    conta = self.conta_corrente.to_s.rjust(7,'0')

    numero = "#{banco}#{self.moeda}#{fator}#{valor_documento}#{agencia}#{carteira}#{numero_documento}#{conta}0"
    numero.size == 43 ? numero : nil
  end
end